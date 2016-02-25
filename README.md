# AtoM - Access to memory

## About

- MySQL is not included in this image, it needs to be linked.

## Usage

docker run –link your-mysql:mysql -e DB_USER=your-dbuser -e DB_PW=yourdbpass -e DB_NAME=yourdbname governoregionalazores/atom-accesstomemory

