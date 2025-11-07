#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Script: acm_route53_request_and_wait.sh
#
# Purpose:
#   • Request a public certificate using AWS Certificate Manager (ACM)
#   • Optionally create DNS validation records in Route 53
#   • Wait until the certificate is ISSUED
#   • Output certificate ARN and region in JSON for downstream automation
#
# Usage:
#   ./acm_route53_request_and_wait.sh \
#     --domain example.com \
#     [--alt-names "www.example.com,api.example.com"] \
#     [--region us‑east‑1] \
#     [--hosted-zone-id Z123456ABCDEFG]
#
# Requirements:
#   • AWS CLI configured & has permissions: acm:RequestCertificate,
#     acm:DescribeCertificate, acm:WaitCertificateValidated,
#     route53:ChangeResourceRecordSets (if hosted‑zone‑id given)
#   • jq installed
#   • If CloudFront use, region must be us‑east‑1 (ACM certificate must be there)
# -----------------------------------------------------------------------------

# Variables and defaults
DOMAIN="www.jenom.com"
ALT_NAMES=""
REGION="us-east-1"
HOSTED_ZONE_ID=""
LOG_PREFIX="[ACM‑Route53]"
CertificateArn="arn:aws:acm:us-east-1:123456789012:certificate/abcdefg-1234-5678-abcd-efghijklmnop"

usage() {
  echo "$LOG_PREFIX Usage:"
  echo "  $0 --domain DOMAIN [--alt-names \"ALT1,ALT2\"] [--region REGION] [--hosted-zone-id HOSTED_ZONE_ID]"
  exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --domain)
      DOMAIN="$2"; shift 2 ;;
    --alt-names)
      ALT_NAMES="$2"; shift 2 ;;
    --region)
      REGION="$2"; shift 2 ;;
    --hosted-zone-id)
      HOSTED_ZONE_ID="$2"; shift 2 ;;
    -*)
      echo "$LOG_PREFIX Unknown option: $1" >&2; usage ;;
    *)
      echo "$LOG_PREFIX Unexpected argument: $1" >&2; usage ;;
  esac
done

# Validate required parameter
if [[ -z "$DOMAIN" ]]; then
  echo "$LOG_PREFIX Error: --domain is required" >&2
  usage
fi

echo "$LOG_PREFIX Requesting ACM certificate for domain: $DOMAIN"
if [[ -n "$ALT_NAMES" ]]; then
  echo "$LOG_PREFIX Subject Alternative Names: $ALT_NAMES"
fi
echo "$LOG_PREFIX Region: $REGION"

# Prepare ACM request command
REQ_ARGS=( aws acm request-certificate \
           --domain-name "$DOMAIN" \
           --validation-method DNS \
           --region "$REGION" \
           --output json \
           --query CertificateArn
         )

if [[ -n "$ALT_NAMES" ]]; then
  IFS=',' read -r -a ALT_ARRAY <<< "$ALT_NAMES"
  REQ_ARGS+=( --subject-alternative-names "${ALT_ARRAY[@]}" )
fi

# Request certificate
CERT_ARN=$( "${REQ_ARGS[@]}" )
if [[ -z "$CERT_ARN" ]]; then
  echo "$LOG_PREFIX Error: Failed to get CertificateArn." >&2
  exit 2
fi
echo "$LOG_PREFIX Certificate ARN: $CERT_ARN"

# Retrieve DNS validation options
echo "$LOG_PREFIX Retrieving DNS validation records..."
VALIDATION_JSON=$( aws acm describe-certificate \
                     --certificate-arn "$CERT_ARN" \
                     --region "$REGION" \
                     --output json \
                     --query "Certificate.DomainValidationOptions" )

# Loop through each validation record
echo "$VALIDATION_JSON" | jq -c '.[]' | while read -r rec; do
  NAME=$( jq -r '.ResourceRecord.Name' <<< "$rec" )
  VALUE=$( jq -r '.ResourceRecord.Value' <<< "$rec" )
  echo "$LOG_PREFIX DNS‑validation record:"
  echo "  Name : $NAME"
  echo "  Value: $VALUE"
  echo ""
  if [[ -n "$HOSTED_ZONE_ID" ]]; then
    echo "$LOG_PREFIX Creating/UPSERT record in Route53 (hosted‑zone: $HOSTED_ZONE_ID)…"
    CHANGE_JSON=$( jq -n \
      --arg name "$NAME" \
      --arg value "$VALUE" \
      '{
         "Comment": "ACM DNS validation record",
         "Changes": [
           {
             "Action": "UPSERT",
             "ResourceRecordSet": {
               "Name": $name,
               "Type": "CNAME",
               "TTL": 300,
               "ResourceRecords":[ { "Value": $value } ]
             }
           }
         ]
       }' )
    aws route53 change-resource-record-sets \
      --hosted-zone-id "$HOSTED_ZONE_ID" \
      --change-batch "$(jq -c . <<< "$CHANGE_JSON")" \
      --output json
    echo "$LOG_PREFIX Change submitted; verify propagation."
  else
    echo "$LOG_PREFIX No hosted‑zone‑id provided — please create the CNAME record manually."
  fi
done

# Optional wait for DNS propagation (basic loop)
if [[ -n "$HOSTED_ZONE_ID" ]]; then
  echo "$LOG_PREFIX Waiting for DNS propagation (simple check)…"
  for attempt in {1..12}; do
    echo "$LOG_PREFIX Propagation attempt $attempt/12..."
    ALL_GOOD=true
    # verify each record resolves to the expected value
    echo "$VALIDATION_JSON" | jq -c '.[]' | while read -r rec; do
      NAME=$( jq -r '.ResourceRecord.Name' <<< "$rec" )
      VALUE=$( jq -r '.ResourceRecord.Value' <<< "$rec" )
      # Use dig to check CNAME
      if ! dig +short "$NAME" | grep -q "$VALUE"; then
        ALL_GOOD=false
      fi
    done
    if [[ "$ALL_GOOD" == true ]]; then
      echo "$LOG_PREFIX DNS records appear propagated."
      break
    fi
    sleep 30
  done
fi

# Wait for issuance
echo "$LOG_PREFIX Waiting for certificate to be validated and issued..."
aws acm wait certificate-validated \
  --certificate-arn "$CERT_ARN" \
  --region "$REGION"

STATUS=$( aws acm describe-certificate \
             --certificate-arn "$CERT_ARN" \
             --region "$REGION" \
             --query "Certificate.Status" \
             --output text )

if [[ "$STATUS" == "ISSUED" ]]; then
  echo "$LOG_PREFIX Certificate issued!"
else
  echo "$LOG_PREFIX Error: Certificate status is $STATUS" >&2
  exit 3
fi

# Final output
cat <<EOF
{
  "CertificateArn": "$CERT_ARN",
  "Region": "$REGION"
}
EOF

exit 0