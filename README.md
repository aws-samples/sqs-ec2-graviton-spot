## Event-driven architecture with Graviton and Spot

This is a sample application that demonstrates how to build a sustainable architecture pattern according to the [AWS Well-Architected Sustainability Pillar](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/best-practices-for-sustainability-in-the-cloud.html) using the following services:

* [Amazon Simple Queue Service(SQS)](https://aws.amazon.com/sqs/)
* [AWS Graviton Processors](https://aws.amazon.com/ec2/graviton/)
* [Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/)
* [Amazon Simple Storage Service(S3)](https://aws.amazon.com/s3/)
* [AWS Auto Scaling](https://aws.amazon.com/autoscaling/)
* [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/)

![Architecture](/images/sqs-ec2-graviton-asg.svg)

Asynchronous and scheduled processing are key techniques for improving the sustainability of cloud architectures. In this lab, we will explore strategies for designing and implementing asynchronous, queue-driven systems on AWS to minimize resource usage and maximize efficiency.

This demo focuses specifically on the [Software and architecture](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/software-and-architecture.html) best practices for sustainability in the cloud.

## Step 1 - Explaining the solution
This lab will use:
- Amazon SQS for queue-driven approach
- Auto-scaling workers adjusting dynamically to optimize resource utilization
- AWS Graviton CPUs for excellent energy efficiency
- Spot instances for reducing idle capacity

These are the steps of the workflow:

1. We upload a picture to an S3 bucket
2. The bucket is configured to trigger an event as soon as it receives a new file
3. The event will be sent to an SQS queue 
4. As events gather, the queue will generate Amazon CloudWatch metrics
5. Our Auto Scaling Group uses a Dynamic Scaling Policy based on a certain metric that will increase and decrease the number of EC2 Instances
6. The Graviton & Spot based instances will retrieve the workload information from the queue and will execute it
7. Original image is fetched and the processed one is uploaded into the S3 bucket

## Step 2 - Deploying the solution
An automated deployment solution is provided with this demo using a CloudFormation template that you can provision directly in your own AWS account and in your Region of preference. The [sqs-ec2-graviton-spot.yaml](sqs-ec2-graviton-spot.yaml) is used to set up all resources using AWS CloudFormation.

You can deploy the resources using the default parameters or modify them according to the description.

![CFNTemplate](/images/CFNQuickCreate.jpg)

## Step 3 - Testing the solution
The stack includes an Amazon Simple Storage Service (S3) bucket with a CloudWatch trigger to push notifications to an SQS queue after an image is uploaded to the Amazon S3 bucket. The scope is to convert the `jpg` image to `pdf`. Once the message is in the queue, it is picked up by the application running on the EC2 instances in the Auto Scaling group. The EC2 instances are using sustainable and efficient Graviton processors. Moreover, this setup will leverage EC2 Spot instances. The image is converted to `pdf`, and the instance is protected from scale-in for as long as it has an active processing job. After the workload has been successful processed, the Auto Scaling group will reduce the number of workers, thus reducing energy waste, lower costs, and minimize environmental footprints.

## Step 4 - Conclusions and cleanup
This workshop demonstrates how to architect fault tolerant worker tiers in a sustainable way. If your queue worker tiers and workload needs are fault tolerant, you can increase your application’s efficiency and sustainability by implementing a queue-driven design. The main best practices covered in this lab are:

- Optimize systems to provision and consume only the resources needed for each workload.
- Scale up compute using auto-scaling services for processing messages asynchronously. This allows consuming resources to be right-sized.
- Use message queuing if you have relaxed availability requirements, reducing the infrastructure needed for workers running all the time.

To cleanup this lab, open the [CloudFormation console](https://console.aws.amazon.com/cloudformation/) and:
- Ensure you select the same region you used to deploy this workshop.
- Select the CloudFormation stack you used and click **Delete**.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.