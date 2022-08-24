https://jfrog.com/screencast/using-the-artifactory-terraform-provider/  and the blog https://jfrog.com/blog/replicate-artifactory-configuration-with-terraform-provider-plugin/ helped me to create this working terraform Artifactory configuration .

## Artifactory
The [sample.tf](https://github.com/jfrog/terraform-provider-artifactory/blob/master/sample.tf) at https://github.com/jfrog/terraform-provider-artifactory contains a lot of the Terraform "Artifactory" resources .

The docs is  in  https://registry.terraform.io/providers/jfrog/artifactory/latest/docs .

This Terraform Provider Plugin is open sourced  and you can find the code in the git repository https://github.com/jfrog/terraform-provider-artifactory 

## Xray
The [sample.tf](https://github.com/jfrog/terraform-provider-xray/blob/master/sample.tf) at https://github.com/jfrog/terraform-provider-xray contains a lot of the Terraform "Xray" resources .

The docs is  in  https://registry.terraform.io/providers/jfrog/xray/latest/docs .

This Terraform Provider Plugin is open sourced  and you can find the code in the git repository https://github.com/jfrog/terraform-provider-xray 

## Project
The [sample.tf](https://github.com/jfrog/terraform-provider-project/blob/master/sample.tf) at https://github.com/jfrog/terraform-provider-project contains a lot of the Terraform "Project" resources .

The docs is  in  https://registry.terraform.io/providers/jfrog/project/latest/docs .

This Terraform Provider Plugin is open sourced  and you can find the code in the git repository https://github.com/jfrog/terraform-provider-project


## Using your own terraform.tfvars
Once you do the 
```
git clone https://git.jfrog.info/scm/profs/terraform_test.git
or
git clone https://github.com/sureshvenkatesan/terraform_test.git
```
, if you want to make changes to the terraform.tfvars but do not want git 
to track the change then in local do the step from https://stackoverflow.com/questions/13630849/git-difference-between-assume-unchanged-and-skip-worktree#

```
git update-index --skip-worktree <RELATIVE_PATH>
i.e
git update-index --skip-worktree terraform.tfvars
```

## Best practice.
You can run terraform plamn and apply using different tfvar files ( for each JPD or even tfvars for diferent team resources  in the same JPD)
```
terraform apply -var-file us-west.tfvars
or
terraform apply -var-file us-east.tfvars
or
terraform apply -var-file us-east-teamA.tfvars

```
Note: Do not mix the tfstate from different  JPD's or environments by running the  "terraform apply" in seperate folders
so that you can get different tfstate files 
Also within a JPD  keep team based tfstate seperate so that someone does not accidentally do "terraform destroy" and destroy the work of all the teams ( in all the JPDs). 
This way each team can be made responsible for their own tfstate so that if they destroy it they own the responsibility  and do not affect other teams.

## Creating terraform configuration for already existing resources in Artifactory

As mentioned in [Import Terraform Configuration](https://learn.hashicorp.com/tutorials/terraform/state-import?
in=terraform/state) :
```text
Terraform also supports bringing existing infrastructure under its management. To do so, you can use the import command to migrate resources into your Terraform state file. The import command does not currently generate the configuration for the imported resource, so you must write the corresponding configuration block to map the imported resource to it.
```

So you have to use a step by step approach to generate the  terraform configuration script like the [artifactory_sample.tf](artifactory/artifactory_sample.tf), for already created 
resources/entities  ( example  existing repos , permissions , replication ) in Artifactory and Xray.

1. For existing repositories get the details of all repos using script similar to [export_all_repo_configurations_with_curl.sh](export_all_repo_configurations_with_curl.sh) and then use it 
   to manually create the terraform.tf file that can create the  repositories. 
Example: Some of the repo  attributes that you usually  need 
   to override when creating the repos in target JPD are: includesPattern , excludesPattern , repoLayoutRef, 
   xrayIndex etc.,

2. Now if the repository below already exists in artifactory then how can we update the tfstate with what is in 
   artifactory to match the resources in the [artifactory_sample.tf](artifactory/artifactory_sample.tf)?
   For example tfstate for:
```bash
# Create a new Artifactory remote repository called my-remote
resource "artifactory_remote_npm_repository" "my-remote" {
  key             = "my-remote"
  url             = "https://registry.npmjs.org/"
  repo_layout_ref = "npm-default"
}
```
>>> Do the followig steps :
a) You can use the "terraform import" commands like the ones in [terraform_import.txt](artifactory/terraform_import.txt) to regenerate the terraform.tfstate.

b) Then run the "terrafrom plan" and it will resync some of the attributes that have been initialized using variables like the artifactory user password, replication password , retrieval_cache_period_seconds in virtual reposiktories etc.,

c) run "terraform apply" . Now the tfstate will match what is in artifactory.

d) Again run the "terrafrom plan" and you should see the output:
```text
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```
