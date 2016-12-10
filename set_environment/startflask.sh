#!/bin/bash
FPATH='/path/to/flask/'
VPATH='/path/to/venv/bin'

CFP=$(echo $FPATH | sed 's/$/\//' | sed 's/\/\//\//')
CVP=$(echo $VPATH | sed 's/$/\//' | sed 's/\/\//\//')

source $CVP\activate
if [ ! "$echo $?" -eq 0 ]
then
    echo "The program wasn't able to start the virtual environment."
    echo "Check if the VPATH variable is set to the correct file path."
fi
export FLASK_DEBUG=1
export FLASK_APP=$CFP\app.py

flask run --host=0.0.0.0
