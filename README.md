# Valohai AWS Hybrid Setup - Terraform

This repository contains a Terraform script to deploy the resources required by a Valohai Hybrid setup in AWS.

## Prerequisites

* [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [Install AWS CLI](https://cloud.google.com/sdk/docs/install)
* Configure a new AWS profile with your credentials by running `aws configure --profile myname` on your workstation

## Running the Terraform template

Before running the template you'll need the following information from Valohai:
* `queue_address` that will be used for your queue
* `valohai_assume_user` is the ARN of the user Valohai will use to assume the generated ValohaiMaster-role in your AWS.

You'll also need to generate an SSH Key that will be attached to your Valohai EC2 instances. Run `ssh-keygen -m PEM -f valohai-queue -C ubuntu` locally on your workstation.

Review the `variables.tfvars` file and add your project and region details.

1. Run `terraform init` to initialize a working directory with Terraform configuration files.
2. Run `terraform plan -out="valohai-init" -var-file=variables.tfvars` to create an execution plan and see what kind of changes will be applied to your AWS Project.
3. Finally execute `terraform apply "valohai-init"` to configure the resources needed for a Valohai Hybrid AWS Installation.

After you've created all the resources, you'll need to share the outputs with Valohai (`master_iam`, `secret_name`, `valohai_queue_private_ip`, `valohai_queue_public_ip`)