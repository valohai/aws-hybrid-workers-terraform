output "valohai-queue-public-ip" {
  value = aws_eip.valohai-ip-queue.public_ip
}

output "valohai-queue-private-ip" {
  value = aws_instance.valohai-queue.private_ip
}

output "secret_name" {
  value = aws_secretsmanager_secret.valohai_redis_secret.name
}
