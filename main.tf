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