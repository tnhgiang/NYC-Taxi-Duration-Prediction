variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "ec2_ami" {
  description = "EC2 AMI"
  type        = string
  default     = "ami-047126e50991d067b"
}

##########
# MLflow #
##########
# Tracking server
variable "mlflow_tracking_server_sg_name" {
  description = "The name of security group for mlflow tracking server"
  type        = string
  default     = "nycttd-mlflow-tracking-server-sg"
}
variable "mlflow_tracking_server_name" {
  description = "The name of ec2 where mlflow runs tracking server"
  type        = string
  default     = "nycttd-mlflow-tracking-server"
}

# Artifacts store
variable "mlflow_artifacts_store_name" {
  description = "The name of aws bucket where mlflow saves models artifacts"
  type        = string
  default     = "nycttd-mlflow-artifacts-store"
}

# Backend store
variable "mlflow_backend_store_sg_name" {
  description = "The name of security group for mlflow backend store"
  type        = string
  default     = "nycttd-mlflow-backend-store-sg"
}

variable "mlflow_backend_store_name" {
  description = "The name of RDS instance where mlflow saves metadata"
  type        = string
  default     = "nycttd-mlflow-backend-store"
}

variable "mlflow_backend_store_db" {
  description = "The configuration of database for mlflow backend store"
  type        = map(any)
  default = {
    db_name              = "mlflow_backend_db"
    engine               = "postgres"
    engine_version       = "16"
    family               = "postgres16"
    major_engine_version = "16"
    instance_class       = "db.t3.micro"
    allocated_storage    = 5
    storage_encrypted = false
    manage_master_user_password = false
  }
}

variable "mlflow_backend_store_db_username" {
  description = "The name of database username for mlflow"
  type        = string
  sensitive   = true
}
variable "mlflow_backend_store_db_password" {
  description = "The name of database password for mlflow"
  type        = string
  sensitive   = true
}
