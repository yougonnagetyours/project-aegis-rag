# Terraform and provider configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# --- Aegis RAG Project Resources ---

# S3 bucket to store source documents for the RAG knowledge base.

resource "aws_s3_bucket" "rag_documents_poc_bucket" {
  bucket = "aegis-rag-poc-documents-mp"

  # Tags for cost allocation, automation, and resource identification
  tags = {
    Name        = "Aegis RAG PoC - Document Storage"
    Environment = "PoC"
    Project     = "Aegis-RAG"
    Owner       = "michal.potoczny"
  }
}

# --- Amazon Kendra Resources ---

# IAM Role to grant Kendra permissions to operate on our behalf
resource "aws_iam_role" "kendra_role" {
  name = "AegisRAG-Kendra-Role-PoC"

  # Trust policy allowing the Kendra service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "kendra.amazonaws.com"
      }
    }]
  })
}

# The main Kendra Index resource
resource "aws_kendra_index" "aegis_rag_index" {
  # Name of the index as it will appear in the AWS Console
  name = "aegis-rag-poc-index"
  
  # IMPORTANT: Using the Developer Edition to be eligible for the Free Tier
  edition = "DEVELOPER_EDITION"

  # Assign the IAM role created above to this index.
  # Terraform understands this dependency and will create the role first.
  role_arn = aws_iam_role.kendra_role.arn

  description = "Index for the Aegis RAG PoC project."

  tags = {
    Name        = "Aegis RAG PoC - Kendra Index"
    Environment = "PoC"
    Project     = "Aegis-RAG"
    Owner       = "michal.potoczny" # Remember to change this to your details
  }
}