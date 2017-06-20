#importing ssh key to grant access to ansible user
mkdir -p /root/.ssh
echo "${SSHRSAAnsibleUserPrivateKey}" > /root/.ssh/id_rsa_ansible
chmod 400 /root/.ssh/id_rsa_ansible

#adding configs to access ansible server
echo -e "Host ansible\n  HostName ${ANSIBLEDNSFQDN}\n  User ansible-user\n  StrictHostKeyChecking no\n  UserKnownHostsFile=/dev/null\n  IdentityFile /root/.ssh/id_rsa_ansible" >> /root/.ssh/config
chmod 644 /root/.ssh/config
chmod 700 /root/.ssh

#giving ansible access to the instance as root
echo "${SSHRSAAnsibleServerPublicKey}" >> /home/ubuntu/.ssh/authorized_keys
chmod 600 /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh

#accessing ansible served and triggering script to install appropriate packages
while true
do
  HOST=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
  if ssh ansible sudo /opt/ansible/ansible_run.sh ${ROLE} $${HOST}
    then
      break
    else
      sleep 30
  fi
done
