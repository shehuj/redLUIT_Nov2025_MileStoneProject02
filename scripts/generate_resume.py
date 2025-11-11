import os
import argparse
import boto3
import json
import markdown2  # converts markdown to HTML

def get_available_models(region: str):
    """List foundation model IDs available in this AWS region via Bedrock."""
    client = boto3.client("bedrock", region_name=region)
    resp = client.list_foundation_models()
    model_ids = [m["modelId"] for m in resp.get("modelSummaries", [])]
    return model_ids

def call_bedrock_for_html(markdown_html: str, model_id: str, region: str) -> str:
    """
    Use Amazon Bedrock to generate refined HTML from markdown_html.
    """
    client = boto3.client("bedrock-runtime", region_name=region)

    request_body = {
        "messages": [
            {
                "role": "system",
                "content": (
                    "You are a professional resume formatter. "
                    "Convert the input HTML snippet into a clean, standards-compliant, responsive web resume page. "
                    "Ensure semantic HTML, proper headings, and professional layout."
                )
            },
            {
                "role": "user",
                "content": markdown_html
            }
        ],
        "temperature": 0.5,
        "top_p": 0.9,
        "max_tokens": 2048,
        "stop": ["</body></html>"]
    }

    response = client.invoke_model(
        modelId=model_id,
        contentType="application/json",
        accept="application/json",
        body=json.dumps(request_body)
    )

    resp_body = json.loads(response["body"].read())
    if "messages" in resp_body and isinstance(resp_body["messages"], list):
        html = resp_body["messages"][-1]["content"]
    else:
        html = resp_body.get("outputText", "")
    return html

def convert_markdown_to_html(markdown_path: str, output_html_path: str, ai_model: str, region: str):
    with open(markdown_path, 'r', encoding='utf-8') as f:
        markdown_content = f.read()

    base_html = markdown2.markdown(markdown_content)

    refined_html = call_bedrock_for_html(base_html, ai_model, region)

    with open(output_html_path, 'w', encoding='utf-8') as f:
        f.write(refined_html)

    print(f"✅ Converted {markdown_path} → {output_html_path} using model {ai_model}")

def upload_to_s3(local_path: str, bucket: str, key: str, region: str):
    s3 = boto3.client("s3", region_name=region)
    s3.upload_file(local_path, bucket, key)
    print(f"📤 Uploaded {local_path} to s3://{bucket}/{key}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', required=True, help='Path to resume_template.md or resume.md')
    parser.add_argument('--output', required=True, help='Path to output HTML file')
    parser.add_argument('--env', required=True, choices=['beta', 'prod'], help='Environment (beta or prod)')
    parser.add_argument('--model', required=False, help='Bedrock model ID (e.g., ai21.jamba-1-5-large-v1:0)')
    parser.add_argument('--bucket', required=False, help='S3 bucket name')
    parser.add_argument('--region', required=False, help='AWS region for operations (e.g., us-east-1)')
    args = parser.parse_args()

    # Read from env variables as fallback
    model_id = args.model or os.environ.get('RESUME_MODEL_ID')
    bucket_name = args.bucket or os.environ.get('RESUME_BUCKET_NAME')
    region = args.region or os.environ.get('RESUME_AWS_REGION')

    # Validate required values
    missing = []
    if not model_id:
        missing.append('--model or env RESUME_MODEL_ID')
    if not bucket_name:
        missing.append('--bucket or env RESUME_BUCKET_NAME')
    if not region:
        missing.append('--region or env RESUME_AWS_REGION')
    if missing:
        parser.error(f"Missing required configuration: {', '.join(missing)}")

    print("🔍 Checking available Bedrock models in region:", region)
    available = get_available_models(region)
    if model_id not in available:
        print(f"❌ Model '{model_id}' not found in available models for region {region}.")
        print("Available model IDs include:", ", ".join(available[:5]), "…")
        exit(1)

    convert_markdown_to_html(args.input, args.output, model_id, region)

    s3_key = f"{args.env}/index.html"
    upload_to_s3(args.output, bucket_name, s3_key, region)

if __name__ == '__main__':
    main()
print("✅ analyze_resume.py loaded")