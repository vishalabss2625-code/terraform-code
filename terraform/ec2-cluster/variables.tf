# Input variables for EC2 cluster configuration

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EC2 cluster"
  type        = string
  default     = "my-ec2-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "min_size" {
  description = "Minimum number of instances in the cluster"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the cluster"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in the cluster"
  type        = number
  default     = 2
}

variable "key_pair_name" {
  description = "Name of the AWS Key Pair for EC2 access"
  type        = string
  default     = ""
}

variable "app_port" {
  description = "Port for your application"
  type        = number
  default     = 8080
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "development"
    Project     = "terra-P"
  }
}