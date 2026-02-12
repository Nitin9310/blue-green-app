provider "aws" {
  region = "ap-south-1"
}

# --- 1. Network & Security ---
# Get default VPC and Subnets
data "aws_vpc" "default" { default = true }
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group for EFS (Allow NFS traffic from Beanstalk)
resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Allow NFS from Beanstalk"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In prod, restrict this to the Beanstalk SG
  }
}

# --- 2. Shared Storage (EFS) ---
resource "aws_efs_file_system" "app_data" {
  creation_token = "blue-green-efs"
  tags = { Name = "BG-App-Data" }
}

# Mount Targets (Connect EFS to your Subnets)
resource "aws_efs_mount_target" "mount" {
  count           = length(data.aws_subnets.default.ids)
  file_system_id  = aws_efs_file_system.app_data.id
  subnet_id       = tolist(data.aws_subnets.default.ids)[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}

# --- 3. Elastic Beanstalk Application ---
resource "aws_elastic_beanstalk_application" "app" {
  name        = "blue-green-demo"
  description = "Node.js App with EFS"
}

# IAM Instance Profile for Beanstalk
resource "aws_iam_role" "eb_role" {
  name = "aws-elasticbeanstalk-ec2-role-custom"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "web_tier" {
  role       = aws_iam_role.eb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}
resource "aws_iam_instance_profile" "eb_profile" {
  name = "aws-elasticbeanstalk-ec2-profile-custom"
  role = aws_iam_role.eb_role.name
}