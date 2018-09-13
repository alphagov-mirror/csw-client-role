output "role_id" {
  value = "${aws_iam_role.cst_security_inspector_role.id}"
}

output "role_arn" {
  value = "${aws_iam_role.cst_security_inspector_role.arn}"
}

output "policy_id" {
  value = "${aws_iam_role_policy.cst_security_inspector_role_policy.id}"
}
