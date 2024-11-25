terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.77.0"
    }
  }

  required_version = "1.9.8"

  backend "s3" {
    bucket = "nycttd-tfbackend-bucket"
    key    = "nyc-taxi-trip-duration.tfstate"
    region = "ap-southeast-1"
    encrypt = true
  }
}
