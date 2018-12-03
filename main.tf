module "csw_role" {
  source            = "./csw_role"
  prefix            = "${var.csw_prefix}"
  agent_account_id  = "${var.csw_agent_account_id}"
  target_account_id = "${var.csw_target_account_id}"
}
