import os
import argparse
import boto3
import json
# import markdown2  # optional: to convert markdown to HTML if you prefer pre-processing
S3_BUCKET = "milestone02project"  # replace with your S3 bucket name
AWS_REGION = "us-east-1"  # replace with your AWS region
MODEL = "amazon.titan-text-express-v1"  # replace with your desired Bedrock model
ENV = "beta"  # or "prod"
OUTPUT_HTML = "resume.html"
INPUT_MD = "resume_template.md"

def call_bedrock_for_html(markdown_text: str, model_id: str) -> str:
    """
    Use Amazon Bedrock to generate HTML from markdown_text using the specified model.
    """
    client = boto3.client("bedrock-runtime")  # use runtime client for inference
    response = client.invoke_model(
        modelId=model_id,
        input={"text": markdown_text}
    )
    # Extract the generated HTML from response – depends on model’s output format
    html = response["body"].read().decode("utf-8")
    return html

def convert_markdown_to_html(markdown_path: str, output_html_path: str, ai_model: str):
    with open(markdown_path, 'r', encoding='utf-8') as f:
        markdown = f.read()

    # Optionally convert markdown to plain HTML skeleton if desired
    base_html = markdown2.markdown(markdown)  # this gives HTML from markdown2
    # Now ask Bedrock to refine or wrap it
    refined_html = call_bedrock_for_html(base_html, ai_model)

    with open(output_html_path, 'w', encoding='utf-8') as f:
        f.write(refined_html)

    print(f"Converted {markdown_path} → {output_html_path} using model {ai_model}")

def upload_to_s3(local_path: str, bucket: str, key: str, region: str):
    s3 = boto3.client("s3", region_name=region)
    s3.upload_file(local_path, bucket, key)
    print(f"Uploaded {local_path} to s3://{bucket}/{key}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', required=True, help='Path to resume_template.md')
    parser.add_argument('--output', required=True, help='Path to output HTML file')
    parser.add_argument('--env', required=True, choices=['beta','prod'], help='Environment (beta or prod)')
    parser.add_argument('--model', required=True, help='Bedrock model identifier (e.g., “amazon.titan-text-express-v1” or other)')
    parser.add_argument('--bucket', required=True, help='S3 bucket name')
    parser.add_argument('--region', required=True, help='AWS region for S3')
    args = parser.parse_args()

    convert_markdown_to_html(args.input, args.output, args.model)

    s3_key = f"{args.env}/index.html"
    upload_to_s3(args.output, args.bucket, s3_key, args.region)

if __name__ == '__main__':
    main()