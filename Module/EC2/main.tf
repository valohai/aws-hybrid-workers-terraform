# Load public key
resource "aws_key_pair" "valohai-queue-key" {
  key_name   = "valohai-${var.company}-${var.region}"
  public_key = file("${var.ec2_key}")

  tags = {
    Name    = "valohai-queue",
    valohai = 1
  }
}

# Security Groups
resource "aws_security_group" "valohai-sg-workers" {
  name        = "valohai-sg-workers"
  description = "for Valohai workers"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "valohai-sg-workers",
    valohai = 1
  }
}