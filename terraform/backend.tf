terraform {
  cloud {
    organization = "sp-howard"

    workspaces {
      name = "cloud-resume-challenge-backend"
    }
  }
}