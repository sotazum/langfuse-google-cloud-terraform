# Setup on Google Cloud
## Features
- Sreverless hosting on Cloud Run
- Secure data persistance with Cloud SQL and VPC network

## Prerequisites
- Google Cloud account
- gcloud CLI installed
- Terraform installed

## Getting Started
1. Clone the repository and move directories
    ```
    git clone https://github.com/sotazum/langfuse-terraform.git
    cd terraform/google/environments/dev
    ```
2. Set your own variables on `terraform.tfvars`
   - Replace the value surrounded by `< >`

3. Terraform init and apply
    ```
    terraform init
    terraform apply
    ```

4. Migrate Terraform state to GCS
    ```
    terraform init -migrate-state
    ```
    - Then generate `backend.tf` and have Terraform state managed by a GCS bucket

5. Access to Langfuse

    - Check your Cloud Run URL on Google Cloud Console (default: `https://langfuse-<your-project-number>.<your-region>.run.app`)