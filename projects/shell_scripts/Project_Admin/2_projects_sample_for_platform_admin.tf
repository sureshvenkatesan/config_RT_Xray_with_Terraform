# Required for Terraform 0.13 and up (https://www.terraform.io/upgrade-guides/0-13.html)
terraform {
  required_providers {
    artifactory = {
      source  = "registry.terraform.io/jfrog/artifactory"
      version = "8.3.1"
    }
    project = {
      source  = "registry.terraform.io/jfrog/project"
      version = "1.1.16"
    }
  }
}

variable "artifactory_url" {
  description = "The base URL of the Artifactory deployment"
  type        = string
}
variable "artifactory_username" {
  description = "The username for the Artifactory administrator"
  type        = string
}
variable "artifactory_password" {
  description = "The password for the Artifactory administrator"
  type        = string
}
variable "artifactory_token" {
  description = "The token for the Artifactory administrator"
  type        = string
}
# Configure the Artifactory provider
provider "artifactory" {
  url = "${var.artifactory_url}"
  access_token = "${var.artifactory_token}"
  check_license =  false
}

provider "project" {
  url = "${var.artifactory_url}"
  access_token = "${var.artifactory_token}"
  check_license =  false
}

#resource "artifactory_group" "vns1-group1" {
#  name             = "vns1-group1"
#  description      = "group to test role to group mapping in project vns1"
#  admin_privileges = false
#}

# Create a new Artifactory local repository called my-local
resource "artifactory_local_generic_repository" "vns1-sv-generic-local" {
  key          = "vns1-sv-generic-local"
#  project_environments = ["vns1-stage1"]
#  environments = ["vns1-stage1"]
#  project_key = "vns1"
  lifecycle {
    ignore_changes = [
      project_environments,
      project_key
    ]
  }
}

resource "project" "vns1" {

  display_name = "venus1"
  key = "vns1"
  description  = "Venus project created via automation - updated by terraform"
  admin_privileges {
    manage_members   = true
    manage_resources = true
    # manage_security_assets = true # An argument named "manage_security_assets" is not expected her
    index_resources  = true
    # allow_ignore_rules = true # An argument named "allow_ignore_rules" is not expected here
  }
  max_storage_in_gibibytes   = 10
  block_deployments_on_limit = false
  email_notification         = true
#  "storage_quota_bytes": -1,
#  "soft_limit": false,
#  "storage_quota_email_notification": true

  group {
    name  = "sv-project-admin-group"
  roles = [ "Project Admin"]
}
  # , where to use it ?
  role {
    name         = "vns1-developer"
    description  = "Developer role"
    type         = "CUSTOM"
    environments = ["vns1-stage1"]
#    environments = ["DEV"]
    actions      = ["READ_REPOSITORY", "ANNOTATE_REPOSITORY",  "DELETE_OVERWRITE_REPOSITORY", "DEPLOY_CACHE_REPOSITORY" ]
  }

  group {
    name = "vns1-group1" # assume the "vns1-group1" is a SCIM group and already pushed to Artifactory
    roles = ["vns1-developer"]
  }

   repos = ["vns1-sv-generic-local"] # How is the project environment mapped to the repo created? I do not see it
  #mapped. It is mapped to DEV environment by default.

}