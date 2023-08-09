// secrets for a map of env vars
resource "aws_secretsmanager_secret" "secret_map" {
  for_each = var.secrets_map
  name = each.key
  recovery_window_in_days = "0"
}

resource "aws_secretsmanager_secret_version" "secrets" {
  for_each = var.secrets_map
  secret_id     = tostring(each.key)
  secret_string = each.value
  depends_on = [aws_secretsmanager_secret.secret_map]
}

## dont forget to add in variables file the var: secrets_map
## the env var should look as such:  export TF_VAR_secrets_map='{"key":"value","key2":"value2"}'
