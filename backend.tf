terraform {
  backend "gcs" {
    bucket  = "tf-state-prod-vpc"
    prefix  = "terraform/state"
  }
}
