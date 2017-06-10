#!/bin/bash
sudo apt-get -y update
sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update -y
sudo apt-get install ansible -y
echo "${SSHRSAHostPrivateKey}" > /root/.ssh/id_rsa    
chmod 400 /root/.ssh/id_rsa
git clone https://github.com/Neifn/AnsibleNeifn1 /opt/ansible
cd /opt/ansible && ansible-playbook playbook.yml -i hosts -u ubuntu
