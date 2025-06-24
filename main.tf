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

# --- Amazon Bedrock Knowledge Base Resources ---

# IAM Role that grants the Bedrock Knowledge Base service permissions 
# to access other AWS services on our behalf.
resource "aws_iam_role" "bedrock_kb_role" {
  name = "AegisRAG-Bedrock-KB-Role-PoC"

  # Trust policy allowing the Bedrock service to assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "bedrock.amazonaws.com"
      }
    }]
  })
}

# Attaches a pre-made, managed policy from AWS to our role.
# This policy contains all the necessary permissions.
resource "aws_iam_role_policy_attachment" "bedrock_kb_role_policy" {
  role       = aws_iam_role.bedrock_kb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockExecutionRoleForKnowledgeBase"
}

# The Knowledge Base itself. This is the main container for our knowledge.
resource "aws_bedrock_knowledge_base" "aegis_rag_kb" {
  name     = "aegis-rag-poc-knowledge-base"
  role_arn = aws_iam_role.bedrock_kb_role.arn
  
  knowledge_base_configuration {
    type = "VECTOR_KNOWLEDGE_BASE"
    vector_knowledge_base_configuration {
      # We specify which AI model will be used to convert text into vectors (embeddings).
      # Titan Embeddings is a great, cost-effective choice.
      embedding_model_arn = "arn:aws:bedrock:eu-central-1::foundation-model/amazon.titan-embed-text-v1"
    }
  }

  tags = {
    Name        = "Aegis RAG PoC - Knowledge Base"
    Environment = "PoC"
    Project     = "Aegis-RAG"
    Owner       = "Jan.Kowalski" # Zmień na swoje dane
  }
}

# The Data Source, which connects our S3 bucket to the Knowledge Base.
resource "aws_bedrock_knowledge_base_data_source" "s3_data_source" {
  knowledge_base_id = aws_bedrock_knowledge_base.aegis_rag_kb.id
  name              = "aegis-rag-poc-s3-source"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      # Here we reference the S3 bucket we created earlier by its local Terraform name.
      bucket_arn = aws_s3_bucket.rag_documents_poc_bucket.arn
    }
  }
}



