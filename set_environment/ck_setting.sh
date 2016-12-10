#!/bin/bash

echo 'Python Version: ' &> output.log
python -V &>> output.log
echo '- -' &>> output.log
echo 'Virtualenv-2.7' &>> output.log
command -v virtualenv-2.7 &>> output.log
echo '- -' &>> output.log
echo 'Packages' &>> output.log
pip list | grep geocoder &>> output.log
pip list | grep Flask &>> output.log
pip list | grep psycopg2 &>> output.log
rpm -qa | grep openssl-devel &>> output.log
rpm -qa | grep python-devel &>> output.log
rpm -qa | grep libffi-devel &>> output.log
