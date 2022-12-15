# Load public key
resource "aws_key_pair" "valohai-queue-key" {
  key_name   = "valohai-${var.company}-${var.region}"
  public_key = file("${var.ec2_key}")

  tags = {
    Name    = "valohai-queue",
    valohai = 1
  }
}
