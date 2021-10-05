resource "aws_iam_role" "valohai_queue_role" {
  name                  = "ValohaiQueueRole"
  description           = "A Valohai role that's assigned to the Queue EC2 instance"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

  tags = {
    valohai = 1,
  }
}

resource "aws_iam_instance_profile" "valohai_queue_profile" {
  name = "ValohaiQueueInstanceProfile"
  role = aws_iam_role.valohai_queue_role.name
}

resource "aws_iam_role_policy" "valohai_queue_policy" {
  name = "ValohaiQueuePolicy"
  role = aws_iam_role.valohai_queue_role.name

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "0",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "secretsmanager:ResourceTag/valohai": "1"
                }
            }
        },
        {
            "Sid": "1",
            "Effect": "Allow",
            "Action": "secretsmanager:GetRandomPassword",
            "Resource": "*"
        }
    ]
})
}
