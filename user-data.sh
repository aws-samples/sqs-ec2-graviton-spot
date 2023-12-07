#!/bin/bash

INSTANCE_ID=$(TOKEN=`curl -X PUT -s "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id -s)
WORKING_DIR=/root/sqs-ec2-graviton-spot

yum -y --security update

yum -y update aws-cli

yum -y install amazon-cloudwatch-agent jq ImageMagick

aws configure set default.region $REGION

cp -av $WORKING_DIR/spot-instance-interruption-notice-handler.conf /etc/systemd/system/spot-instance-interruption-notice-handler.service
cp -av $WORKING_DIR/convert-worker.conf /etc/systemd/system/convert-worker.service
cp -av $WORKING_DIR/spot-instance-interruption-notice-handler.sh /usr/local/bin/
cp -av $WORKING_DIR/convert-worker.sh /usr/local/bin

chmod +x /usr/local/bin/spot-instance-interruption-notice-handler.sh
chmod +x /usr/local/bin/convert-worker.sh

sed -i "s|us-east-1|$REGION|g" /etc/awslogs/awscli.conf
sed -i "s|%CLOUDWATCHLOGSGROUP%|$CLOUDWATCHLOGSGROUP|g" $WORKING_DIR/awslogs.conf
sed -i "s|%REGION%|$REGION|g" /usr/local/bin/convert-worker.sh
sed -i "s|%S3BUCKET%|$S3BUCKET|g" /usr/local/bin/convert-worker.sh
sed -i "s|%SQSQUEUE%|$SQSQUEUE|g" /usr/local/bin/convert-worker.sh

systemctl daemon-reload
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:$WORKING_DIR/awslogs.conf
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start
systemctl enable convert-worker.service && systemctl restart convert-worker.service
systemctl enable spot-instance-interruption-notice-handler.service && systemctl restart spot-instance-interruption-notice-handler.service