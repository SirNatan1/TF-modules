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

// pulling existing secret that was created manually
# this part will pull the secret
data "aws_secretsmanager_secret" "existing_secret" {
  arn = "<arn-of-the-secret>"
}

# this part pulls the value of the secret
data "aws_secretsmanager_secret_version" "existing_secret" {
  secret_id = data.aws_secretsmanager_secret.existing_secret.id
}

## dont forget to add in variables file the var: secrets_map
## the env var should look as such:  export TF_VAR_secrets_map='{"key":"value","key2":"value2"}'
