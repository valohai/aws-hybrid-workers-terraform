resource "aws_secretsmanager_secret" "valohai_redis_secret" {
  name_prefix = "ValohaiRedisSecret-"
}

resource "random_password" "password" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret_version" "valohai_redis_secret_1" {
  secret_id     = aws_secretsmanager_secret.valohai_redis_secret.id
  secret_string = random_password.password.result
}

# Get the AMI for queue instance
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Load public key
resource "aws_key_pair" "valohai-queue-key" {
  key_name   = "valohai-${var.company}-${var.region}"
  public_key = file("${var.ec2_key}")

  tags = {
    Name = "valohai-queue-key",
  }
}

# Valohai queue instance
resource "aws_instance" "valohai-queue" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.valohai-queue-key.id
  vpc_security_group_ids = ["${var.security_group}"]
  subnet_id              = var.subnet
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 16
  }

  user_data = <<-EOF
    #!/bin/bash
    curl https://raw.githubusercontent.com/valohai/worker-queue/main/host/setup.sh | sudo QUEUE_ADDRESS=${var.queue_address} REDIS_PASSWORD=${random_password.password.result} bash
    EOF

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "valohai-queue",
  }
}

# ElasticIP
resource "aws_eip" "valohai-ip-queue" {
  domain   = "vpc"
  instance = aws_instance.valohai-queue.id

  tags = {
    "Name" = "valohai-queue-ip",
  }
}
