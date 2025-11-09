import os
import json
import uuid
import boto3
from datetime import datetime
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')
bedrock = boto3.client('bedrock-runtime')

def count_tokens(model_id, body_bytes):
    try:
        resp = bedrock.count_tokens(
            modelId=model_id,
            body=body_bytes
        )
        input_tokens = resp.get('inputTokens')
        print(f"[Token Count] model={model_id} input_tokens={input_tokens}")
        return input_tokens
    except ClientError as e:
        print(f"[Warning] Could not count tokens: {e}")
        return None

def invoke_model(model_id, body_bytes, streaming=False):
    if streaming:
        resp = bedrock.invoke_model_with_response_stream(
            modelId=model_id,
            body=body_bytes,
            contentType='application/json',
            accept='application/json'
        )
        result_text = ""
        for event in resp['body']:
            chunk = event.get('chunk')
            if chunk and 'bytes' in chunk:
                result_text += chunk['bytes'].decode('utf-8')
        print(f"[Raw Streaming Output] {result_text}")
    else:
        resp = bedrock.invoke_model(
            modelId=model_id,
            body=body_bytes,
            contentType='application/json',
            accept='application/json'
        )
        result_text = resp['body'].read().decode('utf-8')
        print(f"[Raw Output] {result_text}")
    return result_text

def analyze_html_content(html_content, model_id, streaming=False):
    prompt = f"""
You are an AI ATS analysis engine. Analyze the following HTML resume content and return JSON with these fields:
- analysisId (uuid)
- timestamp (UTC ISO8601)
- aiModel
- wordCount
- atsScore (0–100)
- keywords (list)
- readability (0–100)
- missingSections (list of section names)

HTML content:
{html_content[:5000]}
"""
    request_payload = {
        "inputText": prompt,
        "textGenerationConfig": {
            "maxTokenCount": 512,
            "temperature": 0.2
        }
    }
    body_bytes = json.dumps(request_payload).encode('utf-8')

    # count tokens
    count_tokens(model_id, body_bytes)

    # invoke model
    raw = invoke_model(model_id, body_bytes, streaming=streaming)

    # fallback structure
    result = {
        "analysisId": str(uuid.uuid4()),
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "aiModel": model_id,
        "wordCount": len(html_content.split()),
        "atsScore": None,
        "keywords": [],
        "readability": None,
        "missingSections": []
    }

    try:
        parsed = json.loads(raw)
        result.update(parsed)
    except json.JSONDecodeError:
        print("[Warning] Could not parse JSON from model output; using fallback")

    print("[Final Result] ", json.dumps(result, indent=2))
    return result

def write_to_dynamodb(table_name, item):
    table = dynamodb.Table(table_name)
    try:
        table.put_item(Item=item)
        print(f"[DynamoDB Write] Table={table_name}, Item={item}")
    except ClientError as e:
        print(f"[Error] DynamoDB put_item failed: {e}")

def lambda_handler(event, context):
    # expected to receive something like:
    # {
    #   "html": "<html>...</html>",
    #   "env": "prod",
    #   "table": "MyAnalysisTable",
    #   "model": "anthropic.claude-3-haiku-20240307-v1:0",
    #   "stream": true
    # }
    html = event["html"]
    env = event["env"]
    table_name = event["table"]
    model_id = event["model"]
    streaming = event.get("stream", False)

    result = analyze_html_content(html, model_id, streaming=streaming)
    write_to_dynamodb(table_name, result)

    return {
        "statusCode": 200,
        "body": json.dumps({"analysisId": result["analysisId"]})
    }