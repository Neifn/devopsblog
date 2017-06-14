#!/bin/bash
iptables -t nat -A POSTROUTING -o eth0 -s 0.0.0.0/0 -j MASQUERADE
aws ec2 modify-instance-attribute --instance-id `curl http://169.254.169.254/latest/meta-data/instance-id` --no-source-dest-check --region ${REGION}
aws ec2 associate-address --instance-id `curl http://169.254.169.254/latest/meta-data/instance-id` --allocation-id ${ELASTICIP} --region ${REGION}
aws ec2 create-route --route-table-id ${ROUTETABLEID} --destination-cidr-block 0.0.0.0/0 --instance-id `curl http://169.254.169.254/latest/meta-data/instance-id` --region ${REGION}
