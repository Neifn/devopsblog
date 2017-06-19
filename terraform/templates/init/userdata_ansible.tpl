sudo apt-get -y update
sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update -y
sudo apt-get install ansible -y
sudo apt-get install git

#sending private key to id_rsa file to give ansible access to other instances using this key
mkdir /root/.ssh
echo "${SSHRSAAnsibleServerPrivateKey}" > /root/.ssh/id_rsa    
chmod 400 /root/.ssh/id_rsa
#adding configuration to ssh/config to grant easy access to other instances
echo -e "Host *\n  User ubuntu\n  StrictHostKeyChecking no\n  UserKnownHostsFile=/dev/null" > /root/.ssh/config
chmod 644 /root/.ssh/config

git clone https://github.com/Neifn/AnsibleNeifn1 /opt/ansible
cd /opt/ansible && ansible-playbook playbook.yml -i hosts -u ubuntu

#creating variable which contains ip address of the instance to put complete public key

#creating new user to give other instances limited access to ansible server
useradd -m ansible-user -s /bin/bash
mkdir /home/ansible-user/.ssh
echo "${SSHRSAAnsibleUserPublicKey}" > /home/ansible-user/.ssh/authorized_keys
chmod 600 /home/ansible-user/.ssh/authorized_keys
chmod 700 /home/ansible-user/.ssh
chown -R ansible-user:ansible-user /home/ansible-user/.ssh
echo -e "#!/bin/bash\nsudo ansible-playbook ${1}.yml -i $2, -u ubuntu" > /opt/ansible/ansible_run.sh
chmod +x /opt/ansible/ansible_run.sh
chmod u+x /opt/ansible/ansible_run.sh
