data "template_file" "policy" {
  template = "${file("${path.module}/json/policy.json")}"

  vars {
    prefix      = "${var.csw_prefix}"
    account_id  = "${var.csw_target_account_id}"
  }
}

resource "aws_iam_role_policy" "cst_security_inspector_role_policy" {
  name = "${var.csw_prefix}_CstSecurityInspectorRolePolicy"
  role = "${aws_iam_role.cst_security_inspector_role.id}"

  policy = "${data.template_file.policy.rendered}"
}
