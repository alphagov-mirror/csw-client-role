# csw-client-role

This repository contains a terraform module which creates an AWS 
IAM role and policy in your AWS account which grants access via 
a trust relationship to a lambda function implemented by 
Cloud Security Watch. 

The role grants a number of priviliges to enable a centralised 
account to assume into your AWS account to query Trusted Advisor 
data and other configuration data such as config rules results 
and bespoke rules around security group ingress and egress and 
IAM roles and policies. The full list of granted permissions 
along with the rationale is listed below. 

We have tried to keep the number of allowed actions as small as 
possible in line with the Principle of Least Privilege. 

## Use 

You can implement direct from GitHub or install this repository 
and use the relative path to access the module: 

### Naming 
* _prefix_ - This is a namespace to name things relating to the 
Cloud Security Watch service. In most cases this will be _csw-live_
* _agent_account_ - The Cloud Security Watch service host AWS account
* _target_account_ - The account granting permission to be audited by  

### GitHub

To implement directly from GitHub you just reference the 
repository url as the source of the Terraform module

```
module "csw_role" {
  source            = "git::https://github.com/alphagov/csw-client-role.git"
  prefix            = "${var.csw_prefix}"
  agent_account_id  = "${var.csw_agent_account_id}"
  target_account_id = "${var.csw_target_account_id}"
}
```

### Relative path

Create a terraform file referencing the relative path where this 
repository is installed. 

```
module "csw_role" {
  source            = "relative/path/to/csw_role"
  prefix            = "${var.csw_prefix}"
  agent_account_id  = "${var.csw_agent_account_id}"
  target_account_id = "${var.csw_target_account_id}"
}
```

Populate the tfvars required by the module. 

```
csw_prefix = "csw-live"
csw_agent_account_id = "[our account id]"
csw_target_account_id = "[your account id]"
```

## Policy Statements
### Statement 1 - support.*
For some reason `describe-trusted-advisor-checks` and 
`describe-trusted-advisor-check-results` will not operate 
without the other support permissions. We have tried adding 
these permissions one by one but it seems `support.*` is 
currently a requirement of calling 
`describe-trusted-advisor-check-results` successfully. 

This does grant us permission to submit support cases which we 
do not need but sadly can't avoid. 

### Statements 2 and 3 - iam GetRole, ListRoles, GetRolePolicy 

This statement is limited to the inspector role resource 
`[env]_CstSecurityInspectorRole`. This statement allows us to 
compare our inspector role to the current version in GitHub. 

We need this to ensure that the deployed role grants all the 
permissions required by the current version of the 
Cloud Security Watch. 

### Statement 4 - configservice - Describe* 

This statement allows us to describe config rules and their 
results. At present we are not implementing the config service. 
The plan is to move to a model of deploying custom checks as 
config rules. 

### Statement 5 - iam List* 

This statement is not limited to our inspector role. 
One of the checks we have prioritised is checking whether IAM 
has been configured with a role granting access to users in the 
shared user account. 

### Statement 6 - ec2 DescribeRegions

This statement allows us to get the list of AWS regions so that
can submit regional resource checks against each region in turn. 

Strictly speaking this check is not required in the client 
account but it's easier to do it with the same API client which 
has assumed permission. 

### Statement 6 - ec2 DescribeSecurityGroups

This statement allows us to check the ingress / egress rules 
directly. Trusted Advisor has some ingress / egress rules but 
these don't perform quite the right checks for our environment 
so we have customised the rules and therefore need access to the 
raw data.

### Statement 7 - s3 ListAllBuckets, Get*

This statement allows us to get the configuration settings of 
S3 buckets without granting us any visibility over the bucket 
contents. 

We may need to extend this to check read/write permission of 
the objects in the buckets but we would prefer not having any 
visibility of the bucket contents if possible. 

### Statement 8 - sts GetCallerIdentity 

This statement allows us to check the account ID we have 
assumed into. This is used to compare our bucket policy with 
the policy deployed in the client account.  

### Statement 9 - cloudtrail DescribeCloudTrails, GetCloudTrailStatus 

Allows us to check how cloud trail logging has been set up in 
the target account. 