# We need to declare aws terraform provider. You may want to update the aws region

# terraform {
#   backend "s3" {
#     # Replace this with your bucket name!
#     bucket         = "kaledros"
#     key            = "kaledros/terraform.tfstate"
#     region         = "us-west-1"

#     # Replace this with your DynamoDB table name!
#     dynamodb_table = "kaledros"
#   }
  
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "4.67.0"
#     }
#   }
# }

provider "aws" {
  region  = var.region
  profile = "teelake"  # Use the new user profile
  default_tags {
    tags = {
      Name    = "teelake"
      project = "kaledros-App"
    }
  }
}


# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "kaledros-application-bucket"
  acl    = "private"
}

# Create an SQS queue
resource "aws_sqs_queue" "my_queue" {
  name = "kaledros-application-queue"
}


data "aws_eks_cluster_auth" "kaledros-eks-cluster" {
  name = aws_eks_cluster.kaledros-eks-cluster.id
}

data "aws_eks_cluster" "kaledros-eks-cluster" {
  name = aws_eks_cluster.kaledros-eks-cluster.id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.kaledros-eks-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.kaledros-eks-cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.kaledros-eks-cluster.token
  # load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.kaledros-eks-cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.kaledros-eks-cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.kaledros-eks-cluster.token
    # load_config_file       = false
  }
}
