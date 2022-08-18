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
Note: Do not mix the tfstate from different  JPD's or envoironmnts by running the  "terraform apply" in seperate folders
so that you can get different tfstate files 
Also within a JPD  keep team based tfstate seperate so that someone does not accidentally do "terraform destroy" and destroy the work of all the teams ( in all the JPDs). 
This way each team can be made responsible for their own tfstate so that if they destroy it they own the responsibility  and do not affect other teams.
