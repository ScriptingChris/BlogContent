terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
}

data "azuread_client_config" "current" {}

resource "azuread_group" "excluded-group-name" {
  display_name     = var.ca_excluded_group_name
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}


data "azuread_user" "ca-excluded-user" {
  user_principal_name = var.ca_excluded_user
}

resource "azuread_group_member" "add-user-to-excluded-group" {
  group_object_id  = azuread_group.excluded-group-name.id
  member_object_id = data.azuread_user.ca-excluded-user.id
}


resource "azuread_named_location" "trusted-countries" {
  display_name = var.trusted_location_name
  country {
    countries_and_regions = var.trusted_countries
    include_unknown_countries_and_regions = false
  }
}


resource "azuread_conditional_access_policy" "ca-force-mfa-cloudapps" {
  display_name = var.ca_policy_name
  state        = var.ca_policy_state

  conditions {
    client_app_types    = ["all"]

    applications {
      included_applications = ["All"]
      excluded_applications = []
    }

    locations {
      included_locations = ["All"]
      excluded_locations = [var.trusted_location_name]
    }

    platforms {
      included_platforms = ["all"]
    }

    users {
      included_users = ["All"]
      excluded_users = [var.ca_excluded_user]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }

  session_controls {
    application_enforced_restrictions_enabled = true
    sign_in_frequency                         = 10
    sign_in_frequency_period                  = "hours"
    cloud_app_security_policy                 = "monitorOnly"
  }
}