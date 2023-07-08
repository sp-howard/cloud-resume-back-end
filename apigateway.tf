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
resource "aws_api_gateway_method" "get" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.resource.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

# Integration
resource "aws_api_gateway_integration" "get" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda-function-viewcount.invoke_arn
}

################# OPTIONS (for CORS) #################

# Method
resource "aws_api_gateway_method" "options" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.resource.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

# Method Response
resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true,
  }

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.options,
  ]
}

# Integration
resource "aws_api_gateway_integration" "options" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.resource.id
  http_method          = aws_api_gateway_method.options.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }
}

# Integration Response
resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_integration.options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

################# Deployment #################

# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  /* stage_description = "${md5(file("api-gateway.tf"))}" */
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_method.get,
    aws_api_gateway_integration.get,
    aws_api_gateway_method.options,
    aws_api_gateway_integration.options
  ]
}


# IAM Permission for API Gateway to Execute Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-function-viewcount.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}

# Output Invoke URL for Testing
output "viewcount_invoke_url" {
    value = "${aws_api_gateway_deployment.deployment.invoke_url}/viewcount"
}