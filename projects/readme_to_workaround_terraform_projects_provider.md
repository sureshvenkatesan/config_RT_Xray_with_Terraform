Please use below workaround until https://jfrog-int.atlassian.net/browse/PTRENG-5386 is resolved.

1. The **Platform Admin** can  create the project and the repo using terraform script . 
a) Rename the [1_projects_sample_for_platform_admin.tf.disable](shell_scripts/Project_Admin/1_projects_sample_for_platform_admin.tf.disable)
 to 1_projects_sample_for_platform_admin.tf and 
b) Rename the [2_projects_sample_for_platform_admin.tf](shell_scripts/Project_Admin/2_projects_sample_for_platform_admin.tf)
   to 2_projects_sample_for_platform_admin.tf.disable , so that there is only the required  .tf file in the folder and 
   run as:
```
terraform apply -var-file=terraform.tfvars \
-var="artifactory_url=https://proservices.jfrog.io/artifactory" \
-var="artifactory_token=$PLATFORM_ADMIN"
```

You can see I mapped the role “vns1-developer” to the   default **DEV** global environment only to create the project in 
the first place
2. The Project Admin can then create  the Project level environment  "vns1-stage1"   using  the shell script 
[create_env.sh](shell_scripts/Project_Admin/create_env.sh)

which uses the new POST access/api/v1/projects/$PROJECT_KEY/environments API mentioned in the [2_JFrog_Access_Server_swagger_postman_collection_v2.json](2_JFrog_Access_Server_swagger_postman_collection_v2.json).
```
bash ./create_env.sh https://proservices.jfrog.io  $PROJECT_ADMIN_TOKEN vns1 stage1
```

3. Then edit the terraform file (  1_projects_sample_for_platform_admin.tf ) to map the Project role to the new Project
   environment "vns1-stage1" to look like 2_projects_sample_for_platform_admin.tf .


Apply this modified .tf  using the
Platform Admin credentials ( though ideally the Project Admin should be able to do this after the PTRENG-5386 is fixed).
```
terraform apply -var-file=terraform.tfvars \
-var="artifactory_url=https://proservices.jfrog.io/artifactory" \
-var="artifactory_token=$PLATFORM_ADMIN"
```

But  the  repository in the project ( "vns1-sv-generic-local")  is still assigned to the default DEV environment and not  Project environment "vns1-stage1".  
This will be fixed in PTRENG-5386.

UNtil then you   use the [set_repo_env.sh](./shell_scripts/Project_Admin/set_repo_env.sh) script  as the **Project Admin** 
to map the repo to the  project level environment "vns1-stage1".

```
bash ./set_repo_env.sh https://proservices.jfrog.io  $PLATFORM_ADMIN vns1-sv-generic-local vns1-stage1
```
