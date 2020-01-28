terraform {
  required_version = ">= 0.12.0"
}

# A DigitalOcean personal access token
variable "do_token" {
  description = "Your DigitalOcean personal access token"
  default     = ""
}

provider "digitalocean" {
  token   = var.do_token
  version = "~> 1.12"
}

provider "random" {
  version = "~> 2.2"
}
