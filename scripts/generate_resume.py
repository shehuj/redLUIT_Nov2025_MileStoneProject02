import os
import argparse
import boto3
import json
import markdown2  # converts markdown to HTML

def call_bedrock_for_html(markdown_text: str, model_id: str) -> str:
    """
    Use Amazon Bedrock to generate HTML from markdown_text using the specified model.
    """
    client = boto3.client("bedrock-runtime")

    # Proper Bedrock invoke_model call
    response = client.invoke_model(
        modelId=model_id,
        contentType="application/json",
        accept="application/json",
        body=json.dumps({
            "messages": [
                {
                    "role": "user",
                    "content": f"Convert this Markdown resume into a clean, professional HTML resume:\n\n{markdown_text}"
                }
            ],
            "max_tokens": 2048
        })
    )

    # Decode response body
    response_body = json.loads(response["body"].read())
    refined_html = response_body["output"]["content"][0]["text"]

    return refined_html

def convert_markdown_to_html(markdown_path: str, output_html_path: str, ai_model: str):
    with open(markdown_path, 'r', encoding='utf-8') as f:
        markdown = f.read()

    # Basic conversion before refinement
    base_html = markdown2.markdown(markdown)

    # Bedrock refinement
    refined_html = call_bedrock_for_html(base_html, ai_model)

    with open(output_html_path, 'w', encoding='utf-8') as f:
        f.write(refined_html)

    print(f"✅ Converted {markdown_path} → {output_html_path} using model {ai_model}")

def upload_to_s3(local_path: str, bucket: str, key: str, region: str):
    s3 = boto3.client("s3", region_name=region)
    s3.upload_file(local_path, bucket, key)
    print(f"📤 Uploaded {local_path} to s3://{bucket}/{key}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', required=True, help='Path to resume_template.md')
    parser.add_argument('--output', required=True, help='Path to output HTML file')
    parser.add_argument('--env', required=True, choices=['beta', 'prod'], help='Environment (beta or prod)')
    parser.add_argument('--model', required=True, help='Bedrock model ID (e.g., anthropic.claude-3-sonnet-20240229-v1:0)')
    parser.add_argument('--bucket', required=True, help='S3 bucket name')
    parser.add_argument('--region', required=True, help='AWS region for S3')
    args = parser.parse_args()

    convert_markdown_to_html(args.input, args.output, args.model)

    s3_key = f"{args.env}/index.html"
    upload_to_s3(args.output, args.bucket, s3_key, args.region)

if __name__ == '__main__':
    main()