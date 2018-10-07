terraform {
    backend "s3" {
        bucket         = "spfarm-terraform-state"
        key            = "shared/terraform_development.tfstate"
        region         = "us-west-1"
        encrypt        = true
        dynamodb_table = "terraform-lock"
    }
}