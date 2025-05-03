terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.95"
    }
  }
  backend "s3" {
    bucket  = "0d6e4079e367-aws-cm"
    key     = "account-main/terraform.tfstate"
    region  = "us-east-1"
    profile = "main-opentofu"
  }

  required_version = "~> 1.9.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "main-opentofu"
}

resource "aws_budgets_budget" "max_monthly_costs" {
  name         = "max-monthly-costs"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = "50"
  limit_unit   = "USD"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["cavcrosby@gmail.com"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 75
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["cavcrosby@gmail.com"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["cavcrosby@gmail.com"]
  }
}

resource "aws_organizations_organization" "main" {
  feature_set = "ALL"
}

resource "random_string" "suffix" {
  count   = var.manage_test_account ? 1 : 0
  length  = 3
  numeric = false
  special = false
  upper   = false
}

resource "aws_organizations_account" "test" {
  count             = var.manage_test_account ? 1 : 0
  name              = "test-${random_string.suffix[0].result}"
  email             = "cavcrosby+aws-test-${random_string.suffix[0].result}@gmail.com"
  close_on_deletion = true
  depends_on        = [aws_organizations_organization.main]
}
