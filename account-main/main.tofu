locals {
  primary_contact_email = "cavcrosby@gmail.com"
  registered_domains = toset([
    "cavcrosby.com",
    "cavcrosby.net",
    "cavcrosby.tech",
    "cavcrosby.io",
    "cvby.net",
    ]
  )
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.15"
    }
  }
  backend "s3" {
    bucket  = "0d6e4079e367-aws-cm"
    key     = "account-main/terraform.tfstate"
    region  = "us-east-1"
    profile = "main-opentofu"
  }

  # renovate: datasource=github-releases packageName=opentofu/opentofu versioning=hashicorp
  required_version = "~> 1.10.0"
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
    subscriber_email_addresses = [local.primary_contact_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 75
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [local.primary_contact_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [local.primary_contact_email]
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

data "aws_account_primary_contact" "main" {}

resource "aws_route53_zone" "registered_domains" {
  for_each = local.registered_domains
  name     = each.key
}

resource "aws_route53domains_registered_domain" "registered_domains" {
  for_each    = local.registered_domains
  domain_name = each.key

  name_server {
    name = aws_route53_zone.registered_domains[each.key].name_servers[0]
  }

  name_server {
    name = aws_route53_zone.registered_domains[each.key].name_servers[1]
  }

  admin_contact {
    address_line_1 = data.aws_account_primary_contact.main.address_line_1
    city           = data.aws_account_primary_contact.main.city
    country_code   = data.aws_account_primary_contact.main.country_code
    email          = local.primary_contact_email
    first_name     = "Conner"
    last_name      = "Crosby"
    phone_number = replace(
      data.aws_account_primary_contact.main.phone_number, "/\\s/", "."
    )
    state    = data.aws_account_primary_contact.main.state_or_region
    zip_code = data.aws_account_primary_contact.main.postal_code
  }

  billing_contact {
    address_line_1 = data.aws_account_primary_contact.main.address_line_1
    city           = data.aws_account_primary_contact.main.city
    country_code   = data.aws_account_primary_contact.main.country_code
    email          = local.primary_contact_email
    first_name     = "Conner"
    last_name      = "Crosby"
    phone_number = replace(
      data.aws_account_primary_contact.main.phone_number, "/\\s/", "."
    )
    state    = data.aws_account_primary_contact.main.state_or_region
    zip_code = data.aws_account_primary_contact.main.postal_code
  }

  registrant_contact {
    address_line_1 = data.aws_account_primary_contact.main.address_line_1
    city           = data.aws_account_primary_contact.main.city
    country_code   = data.aws_account_primary_contact.main.country_code
    email          = local.primary_contact_email
    first_name     = "Conner"
    last_name      = "Crosby"
    phone_number = replace(
      data.aws_account_primary_contact.main.phone_number, "/\\s/", "."
    )
    state    = data.aws_account_primary_contact.main.state_or_region
    zip_code = data.aws_account_primary_contact.main.postal_code
  }

  tech_contact {
    address_line_1 = data.aws_account_primary_contact.main.address_line_1
    city           = data.aws_account_primary_contact.main.city
    country_code   = data.aws_account_primary_contact.main.country_code
    email          = local.primary_contact_email
    first_name     = "Conner"
    last_name      = "Crosby"
    phone_number = replace(
      data.aws_account_primary_contact.main.phone_number, "/\\s/", "."
    )
    state    = data.aws_account_primary_contact.main.state_or_region
    zip_code = data.aws_account_primary_contact.main.postal_code
  }
}
