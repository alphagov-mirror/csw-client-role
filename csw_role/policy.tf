data "aws_caller_identity" "current" {}

data "template_file" "policy" {
  template = "${file("${path.module}/json/policy.json")}"

  vars {
    prefix     = "${var.prefix}"
    account_id = "${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_iam_role_policy" "cst_security_inspector_role_policy" {
  name = "${var.prefix}_CstSecurityInspectorRolePolicy"
  role = "${aws_iam_role.cst_security_inspector_role.id}"

  policy = "${data.template_file.policy.rendered}"
}
