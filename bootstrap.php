<?php
define('_ATOM_DIR', '/usr/share/nginx/atom');
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
);
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

