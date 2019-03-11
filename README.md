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

## How it works

![Cloud Security Watch runs Lambda function using an Agent execution role defined in IAM in the AWS account that runs the tool. The “Agent” role is allowed to assume an Inspector role defined in IAM in the client AWS account. This means the Inspector” role must be configured in each account you want to monitor.](./assets/CloudSecurityWatch-operating-model.png) 

When Cloud Security Watch executes it invokes a series of lambda 
functions.

The lambda functions share an IAM execution role.

The client IAM role defined in your account is trusted by the 
lambda execution role in our account allowing us to assume the 
client role to query your account. 

The trust relationship trusts only our lambda execution role 
meaning only lambdas running with that role have access to your 
data. 

The first thing we check on running an audit is that the definition 
of that role matches the master definition in this repository. This 
ensures that the role hasn't been tampered with or become out of 
date. 

As the number of checks carried out by the tool increases we may 
need to add additional permissions and so if this role is not 
maintained the audit may not run completely. 

## Use 

You can include the terraform module into your code in one of 
two ways: 

### Reference direct from GitHub 

```git: csw_inspector_role.tf
module "csw_inspector_role" {
  source                = "git::https://github.com/alphagov/csw-client-role.git"
  region                = "eu-west-1"
  csw_prefix            = "${var.csw_prefix}"
  csw_agent_account_id  = "${var.csw_agent_account_id}"
  csw_target_account_id = "${var.csw_target_account_id}"
}
```

### Install as a local dependency and reference the relative path

```local: csw_inspector_role.tf
module "csw_role" {
  source            = "relative/path/to/csw_role"
  prefix            = "${var.csw_prefix}"
  agent_account_id  = "${var.csw_agent_account_id}"
  target_account_id = "${var.csw_target_account_id}"
}
```

### Define the variables 
In both cases you need to define the variables passed to 
the terraform module.

```csw-variables.tf
variable "csw_prefix" {
    default = "csw-prod"
}
variable "csw_agent_account_id" {}
variable "csw_target_account_id" {}
```

### Create a tfvar file 
Populate the tfvars required by the module

The agent account is the account running the Cloud Security 
Watch service. 

The target account is the account which is to be audited. 

Unless you are setting up a test environment the `csw_prefix`
variable should be set to `csw-prod` for the production 
environment.  

```csw-apply.tfvars
csw_prefix = "[environment]"
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

### Statements 2 & 2.1 - iam GetRole, ListRoles, GetRolePolicy 

This statement is limited to the inspector role resource 
`[env]_CstSecurityInspectorRole`. This statement allows us to 
compare our inspector role to the current version in GitHub. 

We need this to ensure that the deployed role grants all the 
permissions required by the current version of the 
Cloud Security Watch. 

### Statement 3 - configservice - Describe* 

This statement allows us to describe config rules and their 
results. At present we are not implementing the config service. 
The plan is to move to a model of deploying custom checks as 
config rules. 

### Statement 4 - iam List* 

This statement is not limited to our inspector role. 
One of the checks we have prioritised is checking whether IAM 
has been configured with a role granting access to users in the 
shared user account. 

### Statement 5 - ec2 DescribeRegions, DescibeSecurityGroups, DescribeVolumes

#### ec2 DescribeRegions

This statement allows us to get the list of AWS regions so that
can submit regional resource checks against each region in turn. 

Strictly speaking this check is not required in the client 
account but it's easier to do it with the same API client which 
has assumed permission. 

#### ec2 DescribeSecurityGroups

This statement allows us to check the ingress / egress rules 
directly. Trusted Advisor has some ingress / egress rules but 
these don't perform quite the right checks for our environment 
so we have customised the rules and therefore need access to the 
raw data.

### Statement 6 - s3 ListAllBuckets, all configuration Gets
#### GetBucketAcl, GetBucketLogging, GetBucketPolicy, GetEncryptionConfiguration, GetBucketVersioning

This statement allows us to get the configuration settings of 
S3 buckets without granting us any visibility over the bucket 
contents. 

We may need to extend this to check read/write permission of 
the objects in the buckets but we would prefer not having any 
visibility of the bucket contents if possible. 

### Statement 7 - sts GetCallerIdentity 

This statement allows us to check the account ID we have 
assumed into. This is used to compare our bucket policy with 
the policy deployed in the client account.  

### Statements 8 & 8.1 - cloudtrail DescribeTrails, GetTrailStatus 

This statement allows us to read the configuration of cloud 
trail so we can check not only that cloud trail is working but 
also that the cloud trails configured match the monitoring 
requirements.  

### Statements 9 & 9.1 - kms ListKeys, GetKeyRotationStatus, DescribeKey

This statement allows us to check whether KMS is managed by AWS 
or using a Customer Managed Key (CMK). In the case of CMK use 
the check ensures that the customer keys are regularly rotated.

### Statements 10 - rds DescribeDBInstances

This statement allows us to check whether DB instances managed by RDS are encrypted.