module "csw_role" {
  source            = "../csw_role"
  prefix            = "${var.prefix}"
  region            = "${var.region}"
  agent_account_id  = "${var.agent_account_id}"
  target_account_id = "${var.target_account_id}"
}
