/*
output "website_url" {
  description = "The website URL, either via CloudFront if enabled or direct S3 website endpoint otherwise."
  value = (
    var.enable_cloudfront
    ? "https://${aws_cloudfront_distribution.cdn[0].domain_name}/"
    : "http://${module.s3.bucket_name}.s3-website-${var.aws_region}.amazonaws.com/${var.env}/index.html"
  )
}
*/
/*
output "certificate_arn" {
  value = data.external.acm_cert.result["CertificateArn"]
}
output "certificate_region" {
  value = data.external.acm_cert.result["Region"]
}
*/