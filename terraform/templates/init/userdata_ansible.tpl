sudo apt-get -y update
sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update -y
sudo apt-get install ansible -y
sudo apt-get install git -y

#sending private key to id_rsa file to give ansible access to other instances using this key
mkdir /root/.ssh
echo "${SSHRSAAnsibleServerPrivateKey}" > /root/.ssh/id_rsa    
chmod 400 /root/.ssh/id_rsa
#adding configuration to ssh/config to grant easy access to other instances
echo -e "Host *\n  User ubuntu\n  StrictHostKeyChecking no\n  UserKnownHostsFile=/dev/null" > /root/.ssh/config
chmod 644 /root/.ssh/config

git clone https://github.com/Neifn/AnsibleNeifn1 /opt/ansible

#creating new user to give other instances limited access to ansible server
useradd -m ansible-user -s /bin/bash
mkdir /home/ansible-user/.ssh
echo "${SSHRSAAnsibleUserPublicKey}" > /home/ansible-user/.ssh/authorized_keys
chmod 600 /home/ansible-user/.ssh/authorized_keys
chmod 700 /home/ansible-user/.ssh
chown -R ansible-user:ansible-user /home/ansible-user/.ssh

#creating ansible_run.sh to allow remote usage of ansible playbooks
echo '#!/bin/bash
cd /opt/ansible
#running ansible-playbook with set values and sending output to log file
nohup ansible-playbook $${1}.yml -i $2, -u ubuntu >/opt/ansible/$${1}-$( date +"%Y%m%d%H%M" ).log 2>&1 &' > /opt/ansible/ansible_run.sh
chmod +x /opt/ansible/ansible_run.sh

#editing visudo to allow sudo usage of ansible_run.sh
echo 'ansible-user ALL=NOPASSWD: /opt/ansible/ansible_run.sh' | sudo EDITOR='tee -a' visudo
