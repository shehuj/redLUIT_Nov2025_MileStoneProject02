import os
import argparse
import boto3

def convert_markdown_to_html(markdown_path, output_html_path, ai_model):
    with open(markdown_path, 'r', encoding='utf‑8') as f:
        markdown = f.read()

    # 📌 Placeholder for actual AI service call:
    # e.g., html = my_ai_service.generate_html(markdown, model=ai_model)
    html = f"""<html><head><title>Resume</title></head><body>
<h1>Captain CLoud</h1>
<p>Generated with AI model {ai_model}</p>
<!-- Jenom Shehu
jen4rill@gmail.com
USC | Dallas Metroplex, TX
Professional Profile
Results-driven DevOps/SRE Engineer with 8+ years architecting scalable cloud infrastructure, CI/CD pipelines, and container orchestration systems. Proven track record achieving 99.9%+ uptime while reducing deployment times by 75% and infrastructure costs by 30%.
Core Technical Skills
•	Cloud Platforms: AWS (EC2, ECS, S3, RDS, Lambda, CloudFormation, SNS, SQS, ), GCP
•	CI/CD: Jenkins, Harness, GitHub Actions, GitOps
•	Containers & Orchestration: Docker, Kubernetes, Helm, ECS
•	Infrastructure as Code: Terraform, CloudFormation, AWS CDK
•	Monitoring & Observability: Prometheus, Grafana, Loki, Splunk, CloudWatch.
•	Configuration Management: Ansible, Salt Stack, AWS SSM
•	Scripting: Python (Boto3), Bash, Groovy
•	Databases: PostgreSQL, RDS, DynamoDB.
•	Security: IAM, RBAC, SSL/TLS, SAST/DAST scanning, encryption
•	Version Control: Git, GitHub
Professional Experience
Global Logic | Senior Software Engineer (DevOps/SRE) | May 2025 - Present
•	Maintain 99.9%+ uptime for mission-critical infrastructure
•	Architect cloud-native solutions using Kubernetes, Docker, Terraform on AWS/Azure
•	Deploy microservices in Java Spring Boot with 98% improved uptime
•	Reduce MTTR by 40% through Grafana/Prometheus observability
Level Up In Tech | DevOps Engineer (Contract) | May 2025 - Present
•	Build CI/CD pipelines achieving 70% deployment time reduction
•	Implement IaC with Terraform/CloudFormation for auto-scaling environments
•	Deploy full-stack observability reducing MTTR by 40%
•	Lead cloud migration reducing infrastructure costs by 30%
Dun and Bradstreet | Senior Site Reliability Engineer | Nov 2022 - May 2025
•	Reduced deployment time from 2 hours to 30 minutes via Jenkins automation
•	Engineered reusable Terraform modules achieving 80% reduction in provisioning errors
•	Implemented Harness CD pipelines with 99.9% deployment success rate
•	Identified $200K annual savings through cloud cost optimization
•	Deployed comprehensive monitoring with Prometheus, Grafana, ELK, Splunk
House Happy | Senior DevOps/SRE | Aug 2021 - Nov 2022
•	Increased operational efficiency by 60% through Bash/Python automation
•	Reduced MTTR by 40% with automated incident response
•	Deployed scalable task queues using AWS SQS and Lambda
•	Implemented comprehensive monitoring with Prometheus, Grafana, Splunk
Pilot Thomas Logistics | Cloud Support Engineer | Apr 2019 - Aug 2021
•	Achieved 98% successful deployment rate with zero-downtime releases
•	Improved deployment consistency by 75% through Docker containerization
•	Reduced MTTR by 35% through process optimization
•	Maintained 99.5% service availability
Henry Schein | Systems Administrator/Cloud Engineer | Oct 2016 - Apr 2019
•	Achieved 99.9% uptime SLA for Linux infrastructure
•	Reduced manual effort by 70% through Bash automation
•	Deployed enterprise monitoring with Prometheus, Grafana, Loki
Education & Certifications
•	B.Sc. Computer Science | Ahmadu Bello University | 2011
•	AWS Certified Solutions Architect - Associate
•	AWS Certified Cloud Practitioner
•	Google Cloud Certified - Cloud Engineer
Key Achievements
•	Reduced deployment times by 75% using terraform implementation
•	Achieved 99.9%+ uptime across mission-critical services
•	Cut infrastructure costs by 30% via cloud optimization
•	Decreased MTTR by 40-45% through automated monitoring
•	Eliminated $500K annual waste through multi-cloud cost analysis

 -->
</body></html>"""

    with open(output_html_path, 'w', encoding='utf‑8') as f:
        f.write(html)

    print(f"Converted {markdown_path} → {output_html_path} using model {ai_model}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', required=True, help='Path to resume.md')
    parser.add_argument('--output', required=True, help='Path to output HTML file')
    parser.add_argument('--env', required=True, choices=['beta','prod'], help='Environment (beta or prod)')
    parser.add_argument('--model', required=True, help='AI model identifier')
    args = parser.parse_args()

    convert_markdown_to_html(args.input, args.output, args.model)

if __name__ == '__main__':
    main()