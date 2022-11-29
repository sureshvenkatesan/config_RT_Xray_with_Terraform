terraform {
  required_providers {
    xray = {
      source  = "registry.terraform.io/jfrog/xray"
      version = "1.6.0"
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
# Configure the xray provider
provider "xray" {
  url          = var.artifactory_url
  access_token = var.artifactory_token
}
# Take the json in https://git.jfrog.info/projects/PROFS/repos/cli_samples/browse/lab-3/security-policy.json 
# and remove the double quotes on keys using https://csvjson.com/json_beautifier ( check the  "No quotes" + "on keys" )
# Then  convert to HCL using https://www.hcl2json.com/  or https://www.convertsimple.com/convert-json-to-hcl/   
#https://discuss.hashicorp.com/t/inconsistent-syntaxing/7398/3
#https://github.com/kvz/json2hcl


# https://github.com/jfrog/SwampUp2022/blob/main/SUP003-Intro_to_DevSecOps_with_JFrog_Xray/scripts/json/lab1-prod-sec-policy.json

resource "xray_security_policy" "Prod-Security-Policy" {
  description = "This is a Security Policy for production Repos and Builds"
  name        = "Prod-Security-Policy"
  type        = "security"

  rule {
    name = "high"
    criteria {
      min_severity = "high"
    }
    actions {
      webhooks = []
      block_download {
        active = true

        unscanned = false
      }
      block_release_bundle_distribution = false
      fail_build                        = true
      notify_deployer                   = true
      notify_watch_recipients           = false
    }

    priority = 1
  }
}

# https://github.com/jfrog/SwampUp2022/blob/main/SUP003-Intro_to_DevSecOps_with_JFrog_Xray/scripts/json/lab1-prod-lic-policy.json
resource "xray_license_policy" "Prod-License-Policy" {
  name        = "Prod-License-Policy"
  description = "This is a License Policy for Production Repos and Builds"
  type        = "license"


  rule {
    name = "banned"

    criteria {
      banned_licenses = ["GPL-3.0", "BSD 2-Clause"]
      allow_unknown   = true
    }

    actions {
      webhooks = []
      block_download {
        active    = true
        unscanned = false
      }
      block_release_bundle_distribution = false
      fail_build                        = true
      notify_deployer                   = true
      custom_severity                   = "high"


    }
    priority = 1
  }
}

# https://github.com/jfrog/SwampUp2022/blob/main/SUP003-Intro_to_DevSecOps_with_JFrog_Xray/scripts/json/lab2-prod-watch.json
/*=======
 Before creating the watch make sure you have repos  with "xray_index  = true" so that the requirement for the watch_resource
 "type = "all-repos" is satisfied. 

But for the builds there is  no terraform directive to add or update builds so they get indexed by xray 

 You need to use the [Add Builds to Indexing Configuration](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-AddBuildstoIndexingConfiguration)
 or [Update Builds Indexing Configuration](https://www.jfrog.com/confluence/display/JFROG/Xray+REST+API#XrayRESTAPI-UpdateBuildsIndexingConfiguration) REST APIs or  
 index the builds using the UI in the "Xray > Settings>General>Indexed Resources"
 ==========*/

resource "xray_watch" "Prod-Watch" {
  name        = "Prod-Watch"
  description = "This is a watch created for Production Repos and Builds"
  active      = true
  watch_resource {
    type       = "repository"
    bin_mgr_id = "default"
    name       = "s003-libs-release-local"
    repo_type  = "local"

    filter {
      type  = "regex"
      value = ".*"
    }
  }
  watch_resource {
    type       = "build"
    bin_mgr_id = "default"
    name       = "swampup22_s003_mvn_pipeline"

  }
  watch_resource {
    type       = "build"
    bin_mgr_id = "default"
    name       = "swampup22_s003_npm_pipeline"

  }
  assigned_policy {
    name = xray_security_policy.Prod-Security-Policy.name
    type = "security"
  }

  assigned_policy {
    name = xray_license_policy.Prod-License-Policy.name
    type = "license"
  }

  watch_recipients = []
}

