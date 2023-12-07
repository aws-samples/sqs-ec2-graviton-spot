#!/bin/bash

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
WORKING_DIR=/root/sqs-ec2-spot-asg

yum -y --security update

yum -y update aws-cli

yum -y install \
  awslogs jq ImageMagick

aws configure set default.region $REGION

cp -av $WORKING_DIR/awslogs.conf /etc/awslogs/
cp -av $WORKING_DIR/spot-instance-interruption-notice-handler.conf /etc/systemd/system/spot-instance-interruption-notice-handler.service
cp -av $WORKING_DIR/convert-worker.conf /etc/systemd/system/convert-worker.service
cp -av $WORKING_DIR/spot-instance-interruption-notice-handler.sh /usr/local/bin/
cp -av $WORKING_DIR/convert-worker.sh /usr/local/bin

chmod +x /usr/local/bin/spot-instance-interruption-notice-handler.sh
chmod +x /usr/local/bin/convert-worker.sh

sed -i "s|us-east-1|$REGION|g" /etc/awslogs/awscli.conf
sed -i "s|%CLOUDWATCHLOGSGROUP%|$CLOUDWATCHLOGSGROUP|g" /etc/awslogs/awslogs.conf
sed -i "s|%REGION%|$REGION|g" /usr/local/bin/convert-worker.sh
sed -i "s|%S3BUCKET%|$S3BUCKET|g" /usr/local/bin/convert-worker.sh
sed -i "s|%SQSQUEUE%|$SQSQUEUE|g" /usr/local/bin/convert-worker.sh

systemctl daemon-reload && systemctl enable awslogsd.service && systemctl restart awslogsd.service
systemctl enable convert-worker.service && systemctl restart convert-worker.service
systemctl enable spot-instance-interruption-notice-handler.service && systemctl restart spot-instance-interruption-notice-handler.service