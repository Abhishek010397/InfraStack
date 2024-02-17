locals {
  name                = basename(get_terragrunt_dir())
  environment         = basename(dirname(get_terragrunt_dir()))
  default_tags        = {
    customer          = local.name
    customer_env      = local.environment
    live              = "False"
    backup_daily      = "yes"
    backup_weekly     = "yes"
    backup_monthly    = "yes"
    retention_daily   = "7"
    retention_weekly  = ""
    retention_monthly = "200"
  }
  tags                = local.default_tags
}
