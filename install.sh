#!/bin/bash
if [ $# -lt 3 ]
  then
  echo "Not enough arguments provided."
  exit 1
fi

USERNAME=$1
ENVIRONMENT=$2
VENV_NAME=$3
WORKON_HOME=$HOME/.virtualenvs
VENV_BLOCK="export WORKON_HOME=\$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
alias $VENV_NAME='workon $VENV_NAME'"

sudo apt-get update
sudo apt-get install -y python-dev python-pip unzip


pip install virtualenv
pip install virtualenvwrapper

grep -q -F "${VENV_BLOCK}" ~/.bashrc || echo "${VENV_BLOCK}" >> ~/.bashrc
source ~/.bashrc
mkvirtualenv ${VENV_NAME}
export PATH=$PATH:/opt/terraform
pip install -r requirements.txt
fab init:${USERNAME},${ENVIRONMENT}
