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
    Use Amazon Bedrock to generate refined HTML from markdown_html, using Jamba‑1.5 Large schema.
    """
    client = boto3.client("bedrock-runtime", region_name=region)

    # System + user messages: guiding the model to convert resume HTML
    request_body = {
        "messages": [
            {
                "role": "system",
                "content": (
                    "You are a professional resume formatter. "
                    "Convert the input HTML snippet into a clean, standards‑compliant, responsive web resume page. "
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
    # According to the Jamba docs: the output will be in resp_body["messages"] or similar
    if "messages" in resp_body and isinstance(resp_body["messages"], list):
        html = resp_body["messages"][-1]["content"]
    else:
        # fallback if schema slightly differs
        html = resp_body.get("outputText", "")
    return html

def convert_markdown_to_html(markdown_path: str, output_html_path: str, ai_model: str, region: str):
    with open(markdown_path, 'r', encoding='utf‑8') as f:
        markdown_content = f.read()

    base_html = markdown2.markdown(markdown_content)

    refined_html = call_bedrock_for_html(base_html, ai_model, region)

    with open(output_html_path, 'w', encoding='utf‑8') as f:
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
    parser.add_argument('--model', required=True, help='Bedrock model ID (e.g., ai21.jamba‑1‑5-large‑v1:0)')
    parser.add_argument('--bucket', required=True, help='S3 bucket name')
    parser.add_argument('--region', required=True, help='AWS region for operations (e.g., us‑east‑1)')
    args = parser.parse_args()

    print("🔍 Checking available Bedrock models in region:", args.region)
    available = get_available_models(args.region)
    if args.model not in available:
        print(f"❌ Model '{args.model}' not found in available models for region {args.region}.")
        print("Available model IDs include:", ", ".join(available[:5]), "…")
        exit(1)

    convert_markdown_to_html(args.input, args.output, args.model, args.region)

    s3_key = f"{args.env}/index.html"
    upload_to_s3(args.output, args.bucket, s3_key, args.region)

if __name__ == '__main__':
    main()