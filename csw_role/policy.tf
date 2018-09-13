data "template_file" "policy" {
  template = "${file("${path.module}/json/policy.json")}"

  vars {
    prefix      = "${var.prefix}"
    region      = "${var.region}"
    account_id  = "${var.target_account_id}"
  }
}

resource "aws_iam_role_policy" "cst_security_inspector_role_policy" {
  name = "${var.prefix}_CstSecurityInspectorRolePolicy"
  role = "${aws_iam_role.cst_security_inspector_role.id}"

  policy = "${data.template_file.policy.rendered}"
}
