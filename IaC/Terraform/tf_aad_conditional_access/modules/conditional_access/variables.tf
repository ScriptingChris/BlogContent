variable "ca_excluded_group_name" {
    type            = string
    description     = "The name of the group which will be exclueded from the Conditional Access policy"
    default         = "s-az-ca-exclusion"
}

variable "ca_excluded_user" {
    type            = string
    description     = "The UserPrincipalName of the user, which will be added to the policy excluded group"
}

variable "trusted_location_name" {
    type            = string
    description     = "The name of the Trusted Locations policy => for a single or multiple trusted countries"
}

variable "trusted_countries" {
    type            = list
    description     = "List of trusted countries. These countries will not be affected of the Conditional Access policy"
    default         = ["DK"]
}

variable "ca_policy_name" {
    type            = string
    description     = "Name of the Conditional Access Policy"
    default         = "Require MFA - All Cloud Apps - All Devices Outside Denmark"
}

variable "ca_policy_state" {
    type            = string
    description     = "The state of the policy 'enabled', 'disabled', 'enabledForReportingButNotEnforced'"
    default         = "enabledForReportingButNotEnforced"
}



