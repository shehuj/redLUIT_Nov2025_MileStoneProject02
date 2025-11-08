terraform {
  backend "s3" {
    backend_bucket = var.backend_bucket
#    bucket         = "ec2-shutdown-lambda-bucket"      # literal string, not var.backend_bucket
    key            = "milestone-project-02/terraform.tfstate"    # literal string
    region         = "us-east-1"                     # literal string
    dynamodb_table = "dyning_table"  # literal string
    encrypt        = true                             # optional, but recommended
  }
}