output "api_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.counter_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/counter"
}

output "dynamodb_table" {
  value = aws_dynamodb_table.visitor_counter.name
}

output "lambda_function_name" {
  value = aws_lambda_function.visitor_counter.function_name
}
