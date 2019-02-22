variable "csw_prefix" {
    default = "csw-prod"
}
/*
Region is only used for the provider.
If you are implementing our module in your own terraform
it's not needed.
*/
variable "region" {
    default = "eu-west-1"
}
variable "csw_agent_account_id" {}
variable "csw_target_account_id" {}