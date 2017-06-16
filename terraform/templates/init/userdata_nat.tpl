#installing awscli
apt-get update
apt-get install awscli -y

#changign the /etc/sysctl.conf to allow forwarding
sed -i '/#net.ipv4.ip_forward=1/c\net.ipv4.ip_forward=1' /etc/sysctl.conf

#applying the change
sysctl -w net.ipv4.ip_forward="1"

iptables -t nat -A POSTROUTING -o eth0 -s 0.0.0.0/0 -j MASQUERADE
aws ec2 modify-instance-attribute --instance-id `curl http://169.254.169.254/latest/meta-data/instance-id` --no-source-dest-check --region ${REGION}
aws ec2 associate-address --instance-id `curl http://169.254.169.254/latest/meta-data/instance-id` --allocation-id ${ELASTICIP} --region ${REGION}

#checking if route-table exists and is associated to our nat instance
if aws ec2 describe-route-tables --route-table-ids ${ROUTETABLEID} --region ${REGION}  | grep 0.0.0.0/0 
then
  aws ec2 replace-route --route-table-id ${ROUTETABLEID} --destination-cidr-block 0.0.0.0/0 --instance-id `curl http://169.254.169.254/latest/meta-data/instance-id` --region ${REGION}
else
  aws ec2 create-route --route-table-id ${ROUTETABLEID} --destination-cidr-block 0.0.0.0/0 --instance-id `curl http://169.254.169.254/latest/meta-data/instance-id` --region ${REGION}  
fi
