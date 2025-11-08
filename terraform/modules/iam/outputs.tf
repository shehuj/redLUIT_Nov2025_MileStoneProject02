output "ci_cd_role_arn" {
  value = aws_iam_role.ci_cd_role.arn
}

output "ci_cd_policy_arn" {
  value = aws_iam_policy.ci_cd_policy.arn
}

output "ci_cd_role_name" {
  value = aws_iam_role.ci_cd_role.name
}

output "ci_cd_policy_name" {
  value = aws_iam_policy.ci_cd_policy.name
}