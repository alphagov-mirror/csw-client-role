data "template_file" "trust" {
  template = "${file("${path.module}/json/trust.json")}"

  vars {
    prefix      = "${var.csw_prefix}"
    account_id  = "${var.csw_agent_account_id}"
  }
}

resource "aws_iam_role" "cst_security_inspector_role" {
  name = "${var.csw_prefix}_CstSecurityInspectorRole"

  assume_role_policy = "${data.template_file.trust.rendered}"
}
