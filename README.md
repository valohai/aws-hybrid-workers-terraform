# Valohai AWS Hybrid Setup - Terraform

This repository contains a Terraform script to deploy the resources required by a Valohai Hybrid setup in AWS.

## Prerequisites

* [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* Configure a new AWS profile with your credentials by running `aws configure --profile myname` on your workstation

## Running the Terraform template

Before starting deploying the CloudFormation template, you'll need to:

* Generate an SSH key that will be used as the key for the Valohai managed EC2 instances.
  * You can generate a key by running `ssh-keygen -m PEM -f valohai-queue -C ubuntu` locally on your workstation.
* Get deployment details from your Valohai contact:
  * `valohai_assume_user` is the ARN of the user Valohai will use to assume a role in your AWS subscription to manage EC2 instances.
  * `queue_address` will be assigned for the queue in your subscription.
* Update the `variables.tfvars` file and input your details there.
  
To deploy the resources:
* Run `terraform init` to initialize a working directory with Terraform configuration files.
* Run `terraform plan -out="valohai-init" -var-file=variables.tfvars` to create an execution plan and see what kind of changes will be applied to your AWS Project.
* Finally run `terraform apply "valohai-init"` to configure the resources needed for a Valohai Hybrid AWS Installation.

After you've created all the resources, you'll need to share the outputs with your Valohai contact (master_iam, secret_name, valohai_queue_private_ip, valohai_queue_public_ip)

## What will get deployed?

This template is designed to provision the required services in a fresh AWS Account. The following services will be deployed:

* **VPC and Subnets** in the selected region. Valohai will also deploy a Internet Gateway and RouteTables.
* **Two security groups** for Valohai resources:
  * `valohai-sg-workers` that all the Valohai autoscaled EC2 instances will use.
    * By default it doesn't have ports open. You'll have to open ports to allow for example connecting over SSH to the instances.
  * `valohai-sg-queue` for the `valohai-queue` EC2 instance.
    * It will allow app.valohai.com to connect to Redis (over TLS) on port 63790.
    * Allow the autoscaled Valohai workers to connect to Redis on port 63790.
    * Open port 80 for the letencrypt challenge and certificate renewal.

* **EC2 instance** (`valohai-queue`) that's responsible for storing the job queue, job states, and short-term logs. Valohai communicates with this machines (Redis over TLS) to schedule new jobs and access the logs of existing jobs. 
  * You'll need to provide a key pair that can be uploaded to your AWS account for connecting to this instance.
  * The machine will also have an Elastic IP attached to it.

* **A secret** stored in your AWS Secrets Manager. The secret `valohai_redis_server` contains the password for Redis that's located inside in your `valohai-queue` instance.
* **S3 Bucket** where Valohai will upload logs from your executions, commit snapshots, and where by default all the generated artefacts will be uploaded to.
* **IAM Roles:**
  * `ValohaiQueueRole` will be attached to the Valohai Queue instance, and allows it to fetch the generated password from your AWS Secrets Manager. Access is restricted to secrets that are tagged `valohai:1`
  * `ValohaiWorkerRole` is attached to all autoscaled EC2 instances that are launched for machine learning jobs.
  * `ValohaiMaster` is the role that the Valohai service will use to managed autoscaling and EC2 resources, and manage resources in the newly provisioned valohai-data S3 Bucket.

## Removing Valohai resources

To remove all of the created Valohai resources empty your `valohai-data-*` S3 bucket and run `terraform destroy -var-file=variables.tfvars`.
