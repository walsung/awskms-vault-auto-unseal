terraform {
  cloud {
    organization = "eclipse13"

    workspaces {
      name = "awskms-vault-auto-unseal-dev"
    }
  }
}