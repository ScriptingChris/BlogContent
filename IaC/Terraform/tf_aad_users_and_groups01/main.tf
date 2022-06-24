terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
}  


resource "azuread_user" "user" {
  user_principal_name = "tf-test01@scriptingchris.tech"
  display_name        = "TF Test01"
  mail_nickname       = "tf-test01"
  password            = "SomeP@ssw0rd123"
}


#resource "azuread_group" "group" {
#  display_name     = "tf_group01"
#  security_enabled = true
#}


#resource "azuread_group_member" "group_member" {
#  group_object_id  = azuread_group.group.id
#  member_object_id = azuread_user.user.id
#}


