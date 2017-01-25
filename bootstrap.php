<?php
define('_ATOM_DIR', '/usr/share/nginx/atom');
define('_ETC_DIR', '/usr/local/etc');
function getenv_default($name, $default)
{
  $value = getenv($name);
  if (false === $value)
  {
    return $default;
  }
  return $value;
}
function getenv_or_fail($name)
{
  $value = getenv($name);
  if (false === $value)
  {
    echo "Environment variable ${name} is not defined!";
    exit(1);
  }
  return $value;
}
function get_host_and_port($value, $default_port)
{
  $parts = explode(':', $value);
  if (count($parts) == 1)
  {
    $parts[1] = $default_port;
  }
  return array('host' => $parts[0], 'port' => $parts[1]);
}
$CONFIG = array(
  'atom.mysql_dsn'          => 'mysql:dbname='.getenv_or_fail('DB_NAME').';host='.getenv_or_fail('MYSQL_PORT_3306_TCP_ADDR').';port=3306',
  'atom.mysql_username'     => getenv_or_fail('DB_USER'),
  'atom.mysql_password'     => getenv_or_fail('DB_PW'),
  'php.max_execution_time'  => getenv_default('ATOM_PHP_MAX_EXECUTION_TIME', '120'),
  'php.max_input_time'      => getenv_default('ATOM_PHP_MAX_INPUT_TIME', '120'),
  'php.memory_limit'        => getenv_default('ATOM_PHP_MEMORY_LIMIT', '512M'),
  'php.post_max_size'       => getenv_default('ATOM_PHP_POST_MAX_SIZE', '72M'),
  'php.upload_max_filesize' => getenv_default('ATOM_PHP_UPLOAD_MAX_FILESIZE', '64M'),
  'php.max_file_uploads'    => getenv_default('ATOM_PHP_MAX_FILE_UPLOADS', '20'),
  'php.date.timezone'       => getenv_default('ATOM_PHP_DATE_TIMEZONE', 'Atlantic/Azores')

);

#
# /apps/qubit/config/settings.yml
#
copy(_ATOM_DIR.'/apps/qubit/config/settings.yml.tmpl', _ATOM_DIR.'/apps/qubit/config/settings.yml');
#
# /config/propel.ini
#
@unlink(_ATOM_DIR.'/config/propel.ini');
touch(_ATOM_DIR.'/config/propel.ini');
#
# /config/config.php
#
$mysql_config = array(
  'all' => array(
    'propel' => array(
      'class' => 'sfPropelDatabase',
      'param' => array(
        'encoding' => 'utf8',
        'persistent' => true,
        'pooling' => true,
        'dsn' => $CONFIG['atom.mysql_dsn'],
        'username' => $CONFIG['atom.mysql_username'],
        'password' => $CONFIG['atom.mysql_password'],
      ),
    ),
  ),
  'dev' => array(
    'propel' => array(
      'param' => array(
        'classname' => 'DebugPDO',
        'debug' => array(
          'realmemoryusage' => true,
          'details' => array(
            'time' => array('enabled' => true,),
            'slow' => array('enabled' => true, 'threshold' => 0.1,),
            'mem' => array('enabled' => true,),
            'mempeak' => array ('enabled' => true,),
            'memdelta' => array ('enabled' => true,),
          ),
        ),
      ),
    ),
  ),
  'test' => array(
    'propel' => array(
      'param' => array(
        'classname' => 'DebugPDO',
      ),
    ),
  ),
);
$config_php = "<?php\n\nreturn ".var_export($mysql_config, 1).";\n\n?>\n";
@unlink(_ATOM_DIR.'/config/config.php');
file_put_contents(_ATOM_DIR.'/config/config.php', $config_php);

#
# php ini
#
$php_ini = <<<EOT
[PHP]
output_buffering = 4096
expose_php = off
log_errors = on
error_reporting = E_ALL
display_errors = stderr
display_startup_errors = on
max_execution_time = ${CONFIG['php.max_execution_time']}
max_input_time = ${CONFIG['php.max_input_time']}
memory_limit = ${CONFIG['php.memory_limit']}
log_errors = on
post_max_size = ${CONFIG['php.post_max_size']}
default_charset = UTF-8
cgi.fix_pathinfo = off
upload_max_filesize = ${CONFIG['php.upload_max_filesize']}
max_file_uploads = ${CONFIG['php.max_file_uploads']}
date.timezone = ${CONFIG['php.date.timezone']}
session.use_only_cookies = off
opcache.fast_shutdown = on
opcache.max_accelerated_files = 10000
opcache.validate_timestamps = off
apc.enabled = 1 
apc.shm_size = 64M 
apc.num_files_hint = 5000 
apc.stat = 0
EOT;
if ($CONFIG['atom.development_mode'])
{
  $php_ini .= <<<EOT
\n
# Development-specific configuration
expose_php = on
opcache.validate_timestamps = on
EOT;
}
@unlink(_ETC_DIR.'/php/php.ini');
file_put_contents(_ETC_DIR.'/php/php.ini', $php_ini);

