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
* Update the `variables.tfvars` file and input your details there.
  
To deploy the resources:
* Run `terraform init` to initialize a working directory with Terraform configuration files.
* Run `terraform plan -out="valohai-init" -var-file=variables.tfvars` to create an execution plan and see what kind of changes will be applied to your AWS Project.
* Finally run `terraform apply "valohai-init"` to configure the resources needed for a Valohai Hybrid AWS Installation.

After you've created all the resources, you'll need to share the outputs with your Valohai contact (master_iam) and the VPC and subnets where you want Valohai to launch the resources.

## What will get deployed?

This template is designed to provision the required services in a fresh AWS Account. The following services will be deployed:

* **A security group** for Valohai resources:
  * `valohai-sg-workers` that all the Valohai autoscaled EC2 instances will use.
    * By default it doesn't have ports open. You'll have to open ports to allow for example connecting over SSH to the instances.

* **EC2 Key Pair** will upload a EC2 Key Pair that will be used for all workers owned by Valohai.

* **S3 Bucket** where Valohai will upload logs from your executions and commit snapshots. All the generated artefacts will be uploaded to this bucket by default.
* **IAM Roles:**
  * `ValohaiWorkerRole` is attached to all autoscaled EC2 instances that are launched for machine learning jobs.
  * `ValohaiMaster` is the role that the Valohai service will use to manage autoscaling and EC2 resources. The role is also used to manage the newly provisioned `valohai-data-*` S3 Bucket.

## Removing Valohai resources

To remove all of the created Valohai resources empty your `valohai-data-*` S3 bucket and run `terraform destroy -var-file=variables.tfvars`.
