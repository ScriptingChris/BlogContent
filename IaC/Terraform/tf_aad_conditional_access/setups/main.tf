module "force-mfa-ca-policy"  {
    source                  = "../modules/conditional_access"
    ca_excluded_user        = "chris@scriptingchris.tech"
    trusted_location_name   = "MyTrustedLocation"
}