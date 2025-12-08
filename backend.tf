terraform {
  backend "remote" {
    organization = "tunnyein"

    workspaces {
      name = "portfolio-infra"
    }
  }
}
