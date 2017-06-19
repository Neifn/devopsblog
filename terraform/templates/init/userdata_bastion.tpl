useradd -m bastion -s /bin/bash
mkdir -p /home/bastion/.ssh
echo "${SSHRSABastionUserPublicKey}" > /home/bastion/.ssh/authorized_keys
chmod 600 /home/bastion/.ssh/authorized_keys
chmod 700 /home/bastion/.ssh
echo "${SSHRSAHostPrivateKey}" > /home/bastion/.ssh/id_rsa
chmod 400 /home/bastion/.ssh/id_rsa
echo -e "Host *\n  User ubuntu\n  StrictHostKeyChecking no\n  UserKnownHostsFile=/dev/null" > /home/bastion/.ssh/config
chmod 644 /root/.ssh/config
chown -R bastion:bastion /home/bastion/.ssh
