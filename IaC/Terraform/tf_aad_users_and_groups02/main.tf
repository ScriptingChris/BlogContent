terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0.0"
    }
  }
}

provider "azuread" {}

locals {
  users = csvdecode(file("${path.module}/users.csv"))
}

resource "azuread_user" "users" {
  for_each = { for user in local.users : user.first_name => user }
  
  user_principal_name = format(
    "%s%s@%s",
    substr(lower(each.value.first_name), 0 , 1),
    lower(each.value.last_name),
    lower(each.value.domain_name)
  )

  password = format(
    "%s%s%s!",
    lower(each.value.last_name),
    substr(lower(each.value.first_name), 0, 1),
    length(each.value.first_name)
  )

  force_password_change = true

  display_name = "${each.value.first_name} ${each.value.last_name}"
  department   = each.value.department
  job_title    = each.value.job_title
}
