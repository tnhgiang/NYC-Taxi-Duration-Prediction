terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
  }

  required_version = "1.9.8"

  backend "s3" {
    bucket  = "nycttd-tfbackend-bucket"
    key     = "nyc-taxi-trip-duration.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

###########################
# Data sources to get VPC #
###########################
data "aws_vpc" "default" {
  default = true
}

###################
# Create key-pair #
###################
resource "aws_key_pair" "key_pair" {
  key_name   = "nycttd-key-pair"
  public_key = file("~/.ssh/nycttd-key-pair.pub")
}

#########################
# MLflow infrastructure #
#########################
# Security group for ec2
module "mlflow_tracking_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = var.mlflow_tracking_server_sg_name
  description = "Security group for mlflow tracking server"
  vpc_id      = data.aws_vpc.default.id

  # ingress_rules = ["http-80-tcp", "ssh-tcp"]

  ingress_with_cidr_blocks = [
    {
      description = "Allow ssh connection"
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow HTTP connection"
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# ec2 for mlflow tracking server
module "mlflow_tracking_server" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = var.mlflow_tracking_server_name

  instance_type          = "t2.micro"
  ami                    = var.ec2_ami
  key_name               = "nycttd-key-pair"
  vpc_security_group_ids = [module.mlflow_tracking_server_sg.security_group_id]

  tags = {
    Environment = "dev"
  }
}

# s3 bucket for mlflow artifacts store
module "mlflow_artifacts_store" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket                   = var.mlflow_artifacts_store_name
  acl                      = "private"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  force_destroy            = true

  tags = {
    Environment = "dev"
  }
}

# postgresql db for mlflow backend store
module "mlflow_backend_store_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = var.mlflow_backend_store_sg_name
  description = "Security group for mlflow backend store database"
  vpc_id      = data.aws_vpc.default.id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.mlflow_tracking_server_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

}

module "mlflow_backend_store" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.mlflow_backend_store_name

  engine                      = var.mlflow_backend_store_db.engine
  engine_version              = var.mlflow_backend_store_db.engine_version
  family                      = var.mlflow_backend_store_db.family
  major_engine_version        = var.mlflow_backend_store_db.major_engine_version
  instance_class              = var.mlflow_backend_store_db.instance_class
  allocated_storage           = var.mlflow_backend_store_db.allocated_storage
  storage_encrypted           = var.mlflow_backend_store_db.storage_encrypted
  manage_master_user_password = var.mlflow_backend_store_db.manage_master_user_password
  skip_final_snapshot         = var.mlflow_backend_store_db.skip_final_snapshot

  db_name  = var.mlflow_backend_store_db.db_name
  username = var.mlflow_backend_store_db_username
  password = var.mlflow_backend_store_db_password

  vpc_security_group_ids = [module.mlflow_backend_store_sg.security_group_id]

  tags = {
    Environment = "dev"
  }
}
