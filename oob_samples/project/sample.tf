# Required for Terraform 0.13 and up (https://www.terraform.io/upgrade-guides/0-13.html)
terraform {
  required_providers {
    project = {
      source = "jfrog/project"
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
provider "project" {
  url = "${var.artifactory_url}"
  access_token = "${var.artifactory_token}"
}

variable "qa_roles" {
  type    = list(string)
  default = ["READ_REPOSITORY", "READ_RELEASE_BUNDLE", "READ_BUILD", "READ_SOURCES_PIPELINE", "READ_INTEGRATIONS_PIPELINE", "READ_POOLS_PIPELINE", "TRIGGER_PIPELINE"]
}

variable "devop_roles" {
  type    = list(string)
  default = ["READ_REPOSITORY", "ANNOTATE_REPOSITORY", "DEPLOY_CACHE_REPOSITORY", "DELETE_OVERWRITE_REPOSITORY", "TRIGGER_PIPELINE", "READ_INTEGRATIONS_PIPELINE", "READ_POOLS_PIPELINE", "MANAGE_INTEGRATIONS_PIPELINE", "MANAGE_SOURCES_PIPELINE", "MANAGE_POOLS_PIPELINE", "READ_BUILD", "ANNOTATE_BUILD", "DEPLOY_BUILD", "DELETE_BUILD", ]
}

resource "project" "myproject" {
  key          = "myproj"
  display_name = "My Project"
  description  = "My Project"
  admin_privileges {
    manage_members   = true
    manage_resources = true
    index_resources  = true
  }
  max_storage_in_gibibytes   = 10
  block_deployments_on_limit = false
  email_notification         = true

  member {
    name  = "user1" // Must exist already in Artifactory
    roles = ["Developer", "Project Admin"]
  }

  member {
    name  = "user2" // Must exist already in Artifactory
    roles = ["Developer"]
  }

  group {
    name  = "qa"
    roles = ["qa"]
  }

  group {
    name  = "release"
    roles = ["Release Manager"]
  }

  role {
    name         = "qa"
    description  = "QA role"
    type         = "CUSTOM"
    environments = ["DEV"]
    actions      = var.qa_roles
  }

  role {
    name         = "devop"
    description  = "DevOp role"
    type         = "CUSTOM"
    environments = ["DEV", "PROD"]
    actions      = var.devop_roles
  }

  repos = ["docker-local", "npm-remote"] // Must exist already in Artifactory
}