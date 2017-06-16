mkdir /root/.ssh
echo "${SSHRSAHostPrivateKey}" > /root/.ssh/id_rsa
chmod 400 /root/.ssh/id_rsa
