#!/bin/bash
cd /opt/ansible
sudo ansible-playbook ${1} -i $2, -u ubuntu
