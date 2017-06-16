#creating special user to access ansible server
useradd -m ansible-user -s /bin/bash

#importing ssh key
mkdir /home/ansible-user/.ssh
echo "${SSHRSAAnsibleUserPrivateKey}" > /home/ansible-user/.ssh/id_rsa
chmod 400 /home/ansible-user/.ssh/id_rsa

#adding configs to access ansible server
echo -e "Host *\n  User ansible-user\n  StrictHostKeyChecking no\n  UserKnownHostsFile=/dev/null" > /home/ansible-user/.ssh/config
chmod 644 /home/ansible-user/.ssh/config
chmod 700 /home/ansible-user/.ssh
chown -R ansible-user:ansible-user /home/ansible-user/.ssh

#giving ansible access to the instance as root
mkdir /root/.ssh
echo "${SSHRSAAnsibleServerPublicKey}" > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
