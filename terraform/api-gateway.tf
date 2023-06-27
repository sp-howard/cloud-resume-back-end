################# API Gateway #################

# REST API
resource "aws_api_gateway_rest_api" "api" {

  name = "viewcount-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Resource
resource "aws_api_gateway_resource" "resource" {
  path_part   = "viewcount"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

################# GET #################

# Method
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integration
resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda-function-viewcount.invoke_arn
}

################# OPTIONS #################

resource "aws_api_gateway_method" "options_method" {
    rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
    resource_id   = "${aws_api_gateway_resource.resource.id}"
    http_method   = "OPTIONS"
    authorization = "NONE"
}


# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  stage_description = "${md5(file("api-gateway.tf"))}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "prod"
}

# IAM Permission for API Gateway to Execute Lambda

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-function-viewcount.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:us-west-1:250029744850:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}