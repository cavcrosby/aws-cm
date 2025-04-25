terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.95"
    }
  }
  backend "s3" {
    bucket  = "b9bf5479484f-aws-cm"
    key     = "terraform.tfstate"
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
