# Required for Terraform 0.13 and up (https://www.terraform.io/upgrade-guides/0-13.html)
terraform {
  required_providers {
    artifactory = {
      source  = "registry.terraform.io/jfrog/artifactory"
      version = "6.11.3"
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
}

# Create a new Artifactory group called terraform
resource "artifactory_group" "test-group" {
  name             = "terraform"
  description      = "test group"
  admin_privileges = false
}

# Create a new Artifactory user called terraform
resource "artifactory_user" "test-user" {
  depends_on = [artifactory_group.test-group]
  name     = "terraform"
  email    = "test-user@artifactory-terraform.com"
  groups   = ["terraform"]
  password = "My super @secret password1"
}

# Create a new Artifactory local repository called my-local
resource "artifactory_local_npm_repository" "my-local" {
  key          = "my-local"
}

# Create a new Artifactory remote repository called my-remote
resource "artifactory_remote_npm_repository" "my-remote" {
  key             = "my-remote"
  url             = "https://registry.npmjs.org/"
  repo_layout_ref = "npm-default"
}


# Create a new Artifactory permission target called testpermission
resource "artifactory_permission_target" "test-perm" {
  depends_on = [artifactory_local_npm_repository.my-local]
  name = "test-perm"
  repo {
    includes_pattern = ["foo/**"]
    excludes_pattern = ["bar/**"]
    repositories     = ["my-local"]
    actions {
      users {
        name        = "anonymous"
        permissions = ["read", "write"]
      }
      groups {
        name        = "readers"
        permissions = ["read"]
      }
    }
  }
  build {
    includes_pattern = ["foo/**"]
    excludes_pattern = ["bar/**"]
    repositories     = ["artifactory-build-info"]
    actions {
      users {
        name        = "anonymous"
        permissions = ["read", "write"]
      }
    }
  }
}


#https://registry.terraform.io/providers/jfrog/artifactory/latest/docs/resources/push_replication
# Create a replication between two artifactory local repositories
resource "artifactory_local_maven_repository" "provider_test_source" {
    key = "provider_test_source"
}

resource "artifactory_local_maven_repository" "provider_test_dest" {
    key = "provider_test_dest"
}

resource "artifactory_push_replication" "foo-rep" {
    repo_key                  = "${artifactory_local_maven_repository.provider_test_source.key}"
    cron_exp                  = "0 0 * * * ?"
    enable_event_replication  = true

    replications {
        #url      = "$var.artifactory_url"
        url      = "${var.artifactory_url}/${artifactory_local_maven_repository.provider_test_dest.key}"
        username = "${var.artifactory_username}"
        password = "${var.artifactory_password}"
        enabled = true
    }
}




# https://registry.terraform.io/providers/jfrog/artifactory/latest/docs/resources/virtual_maven_repository
resource "artifactory_local_maven_repository" "bar" {
  key             = "bar"
  repo_layout_ref = "maven-2-default"
}

resource "artifactory_remote_maven_repository" "baz" {
  key             = "baz"
  url             = "https://repo1.maven.org/maven2/"
  repo_layout_ref = "maven-2-default"
}

resource "artifactory_virtual_maven_repository" "maven-virt-repo" {
  key             = "maven-virt-repo"
  repo_layout_ref = "maven-2-default"
  repositories    = [
    "${artifactory_local_maven_repository.bar.key}",
    "${artifactory_remote_maven_repository.baz.key}"
  ]
  description                = "A test virtual repo"
  notes                      = "Internal description"
  includes_pattern           = "com/jfrog/**,cloud/jfrog/**"
  excludes_pattern           = "com/google/**"
  force_maven_authentication = true
  pom_repository_references_cleanup_policy = "discard_active_reference"
}


# https://github.com/jfrog/SwampUp2022/tree/main/SUP003-Intro_to_DevSecOps_with_JFrog_Xray
# Create a new Artifactory local repository called my-local
resource "artifactory_local_npm_repository" "s003-npm-local" {
  key          = "s003-npm-local"
  description = "The local NPM repository"
  xray_index  = true
}

resource "artifactory_local_maven_repository" "s003-libs-snapshot-local" {
  key          = "s003-libs-snapshot-local"
  description = "The local MAVEN snapshot repository"
  xray_index  = true
}

resource "artifactory_local_maven_repository" "s003-libs-release-local" {
  key          = "s003-libs-release-local"
  description = "The local MAVEN release repository"
  xray_index  = true
}

resource "artifactory_remote_npm_repository" "s003-npm-remote" {
  key             = "s003-npm-remote"
  url             = "https://registry.npmjs.org/"
  repo_layout_ref = "npm-default"
  xray_index  = true
}

resource "artifactory_remote_maven_repository" "s003-maven-remote" {
  key             = "s003-maven-remote"
  url             = "https://repo.maven.apache.org/maven2/"
  repo_layout_ref = "maven-2-default"
  xray_index  = true
}

resource "artifactory_virtual_npm_repository" "s003-npm" {
  key             = "s003-npm"
  repo_layout_ref = "npm-default"
  repositories    = [
    "${artifactory_local_npm_repository.s003-npm-local.key}",
    "${artifactory_remote_npm_repository.s003-npm-remote.key}"
  ]
  description                = "A test virtual repo"
  notes                      = "Internal description"
  default_deployment_repo = "s003-npm-local"
}

resource "artifactory_virtual_maven_repository" "s003-libs-snapshot" {
  key             = "s003-libs-snapshot"
  repo_layout_ref = "maven-2-default"
  repositories    = [
    "${artifactory_local_maven_repository.s003-libs-snapshot-local.key}",
    "${artifactory_remote_maven_repository.s003-maven-remote.key}"
  ]
  description                = "A test virtual repo"
  notes                      = "Internal description"
  default_deployment_repo = "s003-libs-snapshot-local"
}

resource "artifactory_virtual_maven_repository" "s003-libs-release" {
  key             = "s003-libs-release"
  repo_layout_ref = "maven-2-default"
  repositories    = [
    "${artifactory_local_maven_repository.s003-libs-release-local.key}",
    "${artifactory_remote_maven_repository.s003-maven-remote.key}"
  ]
  description                = "A test virtual repo"
  notes                      = "Internal description"
  default_deployment_repo = "s003-libs-release-local"
}

# Create a new Artifactory certificate called my-cert
# https://registry.terraform.io/providers/jfrog/artifactory/latest/docs/resources/certificate
/* =============================
resource "artifactory_certificate" "my-cert" {
  alias   = "my-cert"
  content = file("/key.pem")
}

# This can then be used by a remote repository
resource "artifactory_remote_repository" "my-remote-with-cert" {
  client_tls_certificate = artifactory_certificate.my-cert.alias
  key             = "my-remote-with-cert"
  package_type    = "npm"
  url             = "https://registry.npmjs.org/"
  repo_layout_ref = "npm-default"
}

# Download artifact
data "artifactory_file" "my-file" {
  repository = "my-local"
  path = "/test/artifact.zip"
  output_path = "/Users/danielmi/projects/terraform-provider-config/artifact1.zip"
}

# Provides an Artifactory fileinfo. Reads metadata of files stored in Artifactory repositories
data "artifactory_fileinfo" "my-file" {
  repository = "my-local"
  path = "/test/artifact.zip"
} 
=================================*/