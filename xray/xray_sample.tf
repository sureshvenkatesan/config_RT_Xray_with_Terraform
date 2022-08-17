terraform {
  required_providers {
    xray = {
      source  = "registry.terraform.io/jfrog/xray"
      version = "1.5.1"
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
# Then  conevert to HCL using https://www.hcl2json.com/  or https://www.convertsimple.com/convert-json-to-hcl/   
#https://discuss.hashicorp.com/t/inconsistent-syntaxing/7398/3
#https://github.com/kvz/json2hcl
resource "xray_security_policy" "security1" {
  description = "block high risk vulnerabilities"

  name = "highRisk"


  rule {
    actions {
      block_download {
        active = true

        unscanned = false
      }

      fail_build = true
    }

    criteria {
      min_severity = "High"
    }

    name = "high"

    priority = 1
  }
  rule {
    actions {
      block_download {
        active = false

        unscanned = false
      }

      fail_build = false
    }

    criteria {
      min_severity = "Medium"
    }

    name = "medium"

    priority = 2
  }

  type = "security"
}

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

