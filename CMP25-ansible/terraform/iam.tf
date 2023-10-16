resource "aws_iam_role" "k8_prod" {
  name = "k8_prod" //The policy that grants an entity permission to assume the role.

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF


  tags = {
    Name = "Ec2Role"
  }
}

resource "aws_iam_role_policy" "k8prod_policy" {
  name = "k8prod_policy" //add IAM Policies which allows EC2 instance to access to S3 Bucket.

  role = aws_iam_role.k8_prod.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

