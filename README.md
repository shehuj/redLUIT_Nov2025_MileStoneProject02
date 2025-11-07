# redLUIT_Nov2025_MileStoneProject02
Miles Stone Project 02 Novemeber2025

# AI-Generated Resume Website

## Overview  
This project automates the generation, analysis, and deployment of your professional resume as a publicly accessible website. Written in Markdown, your resume is converted via AI into an HTML website (ATS-optimized), analyzed for keywords and readability, and deployed to AWS using automated CI/CD.  
The pipeline supports two environments: **beta** (for pull requests) and **prod** (for merges to `main`), and tracks deployment & analytics data in Terraform, GitHub Actions, AWS CloudFormation, and AWS services.

## Table of Contents  
- [Key Features](#key-features)  
- [Architecture](#architecture)  
- [Getting Started](#getting-started)  
  - [Prerequisites](#prerequisites)  
  - [Infrastructure Setup](#infrastructure-setup)  
  - [Usage](#usage)  
- [Environment Breakdown](#environment-breakdown)  
- [CI/CD Workflow](#cicd-workflow)  
- [Configuration & Secrets](#configuration-secrets)  
- [Analytics & Tracking](#analytics-tracking)  
- [Customisation & Extensions](#customisation-extensions)  
- [Contributing](#contributing)  
- [License](#license)  
- [Acknowledgements](#acknowledgements)  

---

## Key Features  
- 📝 Source your resume in `resume.md` and convert to an ATS-optimized HTML site via AI.  
- 🔍 Analyze the resume (word count, ATS score, keywords, readability, missing sections) and store results in DynamoDB.  
- 🚀 Deploy to AWS S3 with two distinct prefixes (`beta/` and `prod/`) using fully automated CI/CD.  
- 🌐 Optionally enable AWS CloudFront + HTTPS with ACM certificate by toggling a Terraform variable.  
- 📊 Track deployment metadata (commit SHA, environment, model version, status, URL) in DynamoDB for auditability.  

---

## Architecture  
The infrastructure consists of:  
- An S3 bucket (public website hosting, versioning enabled) that holds both environments.  
- Two DynamoDB tables:  
  - `DeploymentTracking` — logs every deployment event (beta or prod).  
  - `ResumeAnalytics` — stores AI-analysis results of each generated resume version.  
- IAM roles configured for least-privilege access: S3 object operations, DynamoDB writes, infrastructure deployment.  
- Optional CloudFront distribution for HTTPS if enabled via Terraform variable.  
- The CI/CD pipeline runs via GitHub Actions, triggers on PRs and merges, uses Terraform to provision resources, Python scripts to generate and analyze resume, and uploads assets and logs to AWS.

---

## Getting Started  

### Prerequisites  
- AWS account with permission to create S3, DynamoDB, IAM roles, CloudFront, ACM certificate (if used).  
- GitHub repository with this project.  
- GitHub Actions enabled for repo.  
- Terraform installed locally for initial bootstrapping (optional: remote backend).  
- Python 3.9+ and `boto3` library for the scripts.  

### Infrastructure Setup  
1. Clone the repository.  
2. In `terraform/variables.tf` (or `.tfvars`), configure variables:  
   ```hcl
   aws_region = "us-east-1"  
   backend_bucket = "your-tfstate-bucket"  
   backend_lock_table = "your-tf-lock-table"  
   bucket_name = "your-resume-site-bucket"  
   env = "beta"  # or "prod" as appropriate  
   table_deployment_tracking = "DeploymentTracking"  
   table_resume_analytics = "ResumeAnalytics"  
   enable_cloudfront = true  # if you want HTTPS via CloudFront  
   acm_certificate_arn = "arn:aws:acm:... certificate/..."  
3.	Initialize Terraform and apply for the beta environment:
cd terraform  
terraform init  
terraform apply -auto-approve -var="env=beta" …  
4.	Verify the S3 bucket, DynamoDB tables, and (if enabled) CloudFront distribution have been created.
Usage
	•	Modify resume.md with your personal details (name, summary, experience, skills, etc.).
	•	Open a pull request in GitHub → this triggers the beta pipeline:
	•	Terraform applies (if changes) for env=beta.
	•	scripts/generate_resume.py converts Markdown → HTML, uses --model argument for AI model version.
	•	scripts/analyze_resume.py analyzes the generated HTML and writes results to DynamoDB.
	•	Resulting HTML is uploaded to s3://<bucket>/beta/index.html.
	•	DeploymentTracking entry is logged.
	Merge to main → this triggers the prod pipeline:
	•	Terraform applies for env=prod.
	•	The production site is updated by copying beta/index.html → prod/index.html.
	•	DeploymentTracking entry for prod is logged.
	•	View your public resume site:
	•	Without CloudFront: http://<bucket>.s3-website-<region>.amazonaws.com/prod/index.html
	•	With CloudFront: https://<your-distribution-domain>/

Environment Breakdown
Environment
Trigger
S3 Prefix
Purpose
beta
Pull request
beta/
Preview changes before production
prod
Merge to main
prod/
Public, live resume website

CI/CD Workflow
	1.	Pull Request Workflow – File: workflows/on_pull_request.yml
	•	Triggered on PR to main.
	•	Sets up AWS credentials via aws-actions/configure-aws-credentials@v3.
	•	Runs Terraform (env=beta).
	•	Runs generate_resume.py and analyze_resume.py with --model v1.0 (or your model).
	•	Uploads HTML to S3, writes DeploymentTracking and ResumeAnalytics.
	2.	Merge Workflow – File: workflows/on_merge.yml
	•	Triggered on push to main.
	•	Runs Terraform (env=prod).
	•	Copies HTML from beta/index.html to prod/index.html.
	•	Writes DeploymentTracking for prod.

Configuration & Secrets
You must configure the following GitHub repository secrets:
	•	AWS_ACCESS_KEY_ID
	•	AWS_SECRET_ACCESS_KEY
	•	AWS_REGION
	•	BUCKET_NAME
	•	TABLE_DEPLOYMENT_TRACKING
	•	TABLE_RESUME_ANALYTICS
	•	BACKEND_BUCKET
	•	BACKEND_LOCK_TABLE
	•	(Optional) ACM_CERTIFICATE_ARN if you enable CloudFront (enable_cloudfront = true)

Analytics & Tracking
	•	ResumeAnalytics table: stores items containing analysisId, timestamp, aiModel, wordCount, atsScore, keywords, readability, and missingSections.
	•	DeploymentTracking table: logs each deploy event with commitSha, environment, status, s3Url, modelUsed, and timestamp.
	•	Together these give you auditability of how your resume has evolved and how strong it is ATS-wise over time.

Customisation & Extensions
	•	Enable CloudFront + HTTPS: Set enable_cloudfront = true and provide acm_certificate_arn.
	•	Use a custom domain: Configure ACM certificate for your domain, and set CloudFront’s Aliases, update DNS accordingly.
	•	Extend analysis: Add more metrics (e.g., action verbs, fonts, visual structure).
	•	Add API Gateway + Lambda: Provide endpoints to trigger re-generation or fetch analytics history.
	•	Add retention policies: Automatically expire old S3 objects (already included in S3 lifecycle rule).
	•	Add CLI: Allow manual invocation of generate_resume.py and analyze_resume.py locally before deployment.

Contributing
Contributions are welcome! Please open a pull request or issue to discuss major changes.
Make sure your PR:
	•	Is against dev or feature branch (not main).
	•	Includes updated tests or documentation if necessary.
	•	Passes any existing lint or CI checks.

Acknowledgements
Thanks to:
	•	The Best-README-Template￼ for inspiration.  ￼
	•	The “How to Write a Good README” guide from FreeCodeCamp.  ￼
	•	All contributors and the open-source community.

⸻

Last updated: YYYY-MM-DD
---

resume-website/
├── terraform/
│   ├── backend.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── modules/
│   │   ├── s3/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── dynamodb/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── iam/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
├── scripts/
│   ├── generate_resume.py
│   └── analyze_resume.py
├── workflows/
│   ├── on_pull_request.yml
│   └── on_merge.yml
├── resume.md
├── resume_template.md
└── README.md