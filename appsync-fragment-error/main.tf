resource "aws_appsync_graphql_api" "example" {
  name                = "MyAppSyncAPI"
  authentication_type = "API_KEY"
  tags = {
    _custom_id_ = "demo"
  }
  schema = <<EOF
schema {
    query: Query
}

type Data {
  a: Int
  b: Int
  c: Int
}
type Query {
  data: Data!
}
EOF
}

resource "aws_appsync_api_key" "example" {
  api_id = aws_appsync_graphql_api.example.id
}

resource "aws_appsync_datasource" "example" {
  api_id           = aws_appsync_graphql_api.example.id
  name             = "MyDataSource"
  type             = "NONE"
  service_role_arn = aws_iam_role.appsync_role.arn
}

resource "aws_iam_role" "appsync_role" {
  name = "AppSyncServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "appsync.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_appsync_resolver" "hello_query" {
  api_id      = aws_appsync_graphql_api.example.id
  type        = "Query"
  field       = "data"
  data_source = aws_appsync_datasource.example.name

  request_template = <<EOF
{
  "version": "2017-02-28",
  "payload": {}
}
EOF

  response_template = <<EOF
{
  "a": 1,
  "b": 2,
  "c": 3
}
EOF
}
