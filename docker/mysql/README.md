# Instructions

Run, from this directory:

# Build the container
docker build -t mysql-server . #Note the dot, which is the path to the Dockerfile

# Run the container
docker run -d --name=mysql-server mysql/mysql-server:latest
# Get the generated root password:
docker logs mysql-server

# Log into the container interactively:
docker exec -it mysql-server bash

# Start the containerized mysq server, paste the passwd when prompted
mysql -u root -p

# Until you change your root password, you will not be able to exercise any of the superuser privileges, even if you are logged in as root.
# ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123'; 
ALTER USER 'root'@'localhost' IDENTIFIED BY '123';
# 123 is the new pass
update mysql.user set host = '%' where user='root';
# Root is allowed to acess from the outside

FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

CREATE DATABASE MEEP_FPGA;
USE MEEP_FPGA;
CREATE TABLE RESOURCES (BITSTREAM_ID CHAR(20));

CREATE USER 'grafanaReader'@'localhost' IDENTIFIED BY '123'; 
CREATE USER 'grafanaReader'@'%' IDENTIFIED BY '123'; 

GRANT SELECT ON MEEP_FPGA.RESOURCES TO 'grafanaReader';
GRANT CREATE USER ON *.* TO  'grafanaReader'@'%';

FLUSH PRIVILEGES;
