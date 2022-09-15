terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

data "aws_region" "current" {}

resource "aws_vpc_ipam" "test" {
  operating_regions {
    region_name = data.aws_region.current.name
  }
}

resource "aws_vpc_ipam_pool" "test" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.test.private_default_scope_id
  locale         = data.aws_region.current.name
}

resource "aws_vpc_ipam_pool_cidr" "test" {
  ipam_pool_id = aws_vpc_ipam_pool.test.id
  cidr         = "10.0.0.0/8"
}

resource "aws_vpc" "test" {
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.test.id
  ipv4_netmask_length = 16
  depends_on = [
    aws_vpc_ipam_pool_cidr.test
  ]
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.test.id
  cidr_block = cidrsubnet(aws_vpc.test.cidr_block, 8, 0)
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.test.id
  cidr_block = cidrsubnet(aws_vpc.test.cidr_block, 8, 1)
}
