terraform {
    backend "s3" {
        bucket         = "spfarm-terraform-state"
        key            = "shared/terraform_staging_env.tfstate"
        region         = "us-west-1"
        encrypt        = true
        dynamodb_table = "terraform-lock"
    }
}