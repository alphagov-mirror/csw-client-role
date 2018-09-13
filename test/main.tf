module "csw_role" {
  source            = "../csw_role"
  prefix            = "${var.prefix}"
  region            = "${var.region}"
  agent_account_id  = "103495720024"
  target_account_id = "779799343306"
}
