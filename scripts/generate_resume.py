import os
import argparse
import boto3
import json
import markdown2  # converts markdown to HTML

def get_available_models(region: str):
    client = boto3.client("bedrock", region_name=region)
    resp = client.list_foundation_models()  # just call
    return [m["modelId"] for m in resp["modelSummaries"]]

def call_bedrock_for_html(markdown_text: str, model_id: str) -> str:
    client = boto3.client("bedrock-runtime", region_name="us-east-1")

    prompt = (
        "You are a resume‑formatting assistant. Convert the following HTML snippet into a "
        "clean, professional, responsive HTML resume page:\n\n"
        f"{markdown_text}"
    )

    # Decide schema based on model id
    if model_id.startswith("anthropic.claude") or model_id.startswith("amazon.nova") or model_id.startswith("ai21.jamba"):
        request_body = {
            "messages": [
                {"role": "user", "content": prompt}
            ],
            "max_tokens_to_sample": 1024
        }
    else:
        request_body = {
            "inputText": prompt,
            "textGenerationConfig": {
                "maxTokenCount": 1536,
                "temperature": 0.5,
                "topP": 0.9
            }
        }

    response = client.invoke_model(
        modelId=model_id,
        contentType="application/json",
        accept="application/json",
        body=json.dumps(request_body)
    )

    resp_body = json.loads(response["body"].read())
    if "results" in resp_body and isinstance(resp_body["results"], list):
        html = resp_body["results"][0].get("outputText", "")
    elif "messages" in resp_body:
        html = resp_body["messages"][-1]["content"]
    else:
        html = resp_body.get("outputText", "")

    return html

def convert_markdown_to_html(markdown_path: str, output_html_path: str, ai_model: str):
    with open(markdown_path, 'r', encoding='utf‑8') as f:
        markdown = f.read()

    base_html = markdown2.markdown(markdown)
    refined_html = call_bedrock_for_html(base_html, ai_model)

    with open(output_html_path, 'w', encoding='utf‑8') as f:
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
    parser.add_argument('--model', required=True, help='Bedrock model ID')
    parser.add_argument('--bucket', required=True, help='S3 bucket name')
    parser.add_argument('--region', required=True, help='AWS region for operations')
    args = parser.parse_args()

    print("🔍 Checking available Bedrock models in region:", args.region)
    available = get_available_models(args.region)
    if args.model not in available:
        print(f"❌ Model '{args.model}' not found in available models for region {args.region}.")
        print("Available model IDs include:", ", ".join(available[:5]), "…")
        exit(1)

    convert_markdown_to_html(args.input, args.output, args.model)
    s3_key = f"{args.env}/index.html"
    upload_to_s3(args.output, args.bucket, s3_key, args.region)

if __name__ == '__main__':
    main()