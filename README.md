===================================
 ____                _ __  __      
|  _ \ ___  __ _  __| |  \/  | ___ 
| |_) / _ \/ _` |/ _` | |\/| |/ _ \
|  _ <  __/ (_| | (_| | |  | |  __/
|_| \_\___|\__,_|\__,_|_|  |_|\___|
===================================


SETTING THE ENVIRONMENT
***********************

This application use Python, Flask and PostgreSQL + PostGIS.
For help deploy the application, bash scripts were created at the folder "./set_environment".
This scripts were build on CentOS 6.8.
In order to setup the enviroment correctly, run the command in this order:

$ bash 


FOLDERS
*******
./
|
|- README.txt           # This file.
|
|- app/                 # Contain the Flask application. More information on ./app/README_FLASK.txt
|
|- data/                # Contain the data needed for setup the environment. E.g. PostgreSQL Dump.
|   |
|   |- shapes_shelly.dump
|   |      ## Backup from PostgreSQL that contain the data from shapefiles.
|
|
|- set_environment/     # Contain the bash scripts to setup the environment.
    |
    |- inst_postgres.sh
    |    ## This script will install PostgreSQL 9.6 and PostGIS.
    |
    |- set_postgres.sh
    |    ## This script will set the PostgreSQL instance.
    |
    |- inst_python.sh
    |    ## This script will install Python 2.7 and PIP.

REQUIREMENTS
************
postgresql
postgis
python
GEOCODER                                   
yum groupinstall 'Development Tools'
yum install openssl-devel
yum install python-devel
yum install libffi-devel
pip install request[security]
yum install python27-python-psycopg2.x86_64
pip install flask
