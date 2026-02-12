# terraform/environments.tf

# --- BLUE Environment ---
resource "aws_elastic_beanstalk_environment" "blue" {
  name                = "bg-demo-blue"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2023 v6.7.3 running Node.js 20" 

  # --- NETWORK SETTINGS (NEW) ---
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = data.aws_vpc.default.id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", data.aws_subnets.default.ids)
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", data.aws_subnets.default.ids)
  }
  # -------------------------------

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_profile.name
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.micro"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FILE_SYSTEM_ID"
    value     = aws_efs_file_system.app_data.id
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "COLOR_ENV"
    value     = "BLUE"
  }
}

# --- GREEN Environment ---
resource "aws_elastic_beanstalk_environment" "green" {
  name                = "bg-demo-green"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2023 v6.7.3 running Node.js 20"

  # --- NETWORK SETTINGS (NEW) ---
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = data.aws_vpc.default.id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", data.aws_subnets.default.ids)
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", data.aws_subnets.default.ids)
  }
  # -------------------------------

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_profile.name
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.micro"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FILE_SYSTEM_ID"
    value     = aws_efs_file_system.app_data.id
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "COLOR_ENV"
    value     = "GREEN"
  }
}