# redLUIT_Nov2025_MileStoneProject02
Miles Stone Project 02 Novemeber2025

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