https://jfrog.com/screencast/using-the-artifactory-terraform-provider/  and the blog https://jfrog.com/blog/replicate-artifactory-configuration-with-terraform-provider-plugin/ helped me to create this working terraform Artifactory configuration which uses the provider version = "6.11.1" . 

The [sample.tf](https://github.com/jfrog/terraform-provider-artifactory/blob/master/sample.tf) at https://github.com/jfrog/terraform-provider-artifactory contains a lot of the Terraform resources but not all.

The docs is  in  https://registry.terraform.io/providers/jfrog/artifactory/latest/docs
This Terraform Provider Plugin is open sourced  and you can find the code in the git repository https://github.com/jfrog/terraform-provider-artifactory 

Once you do the 
```
git clone https://git.jfrog.info/scm/profs/terraform_test.git
```
if you want to make changes to the terraform.tfvars but do not want git 
to track the change then in local do the step from https://stackoverflow.com/questions/13630849/git-difference-between-assume-unchanged-and-skip-worktree#
i.e git update-index --skip-worktree <RELATIVE_PATH>
```
git update-index --skip-worktree terraform.tfvars
```
