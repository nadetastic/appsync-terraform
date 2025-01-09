// Creates the Base AppSync API
resource "aws_appsync_graphql_api" "wbd_proxy" {
  authentication_type = "API_KEY"
  name                = "WBD Proxy API"

  schema = file("schema.graphql")
}

// Creates API if needed
resource "aws_appsync_api_key" "wbd_proxy_api_key" {
  api_id  = aws_appsync_graphql_api.wbd_proxy.id
  expires = "2025-05-01T04:00:00Z"
}

// Defines the caching options of our api
resource "aws_appsync_api_cache" "wbd_proxy_cache_config" {
  api_id               = aws_appsync_graphql_api.wbd_proxy.id
  api_caching_behavior = "PER_RESOLVER_CACHING"
  type                 = "LARGE"
  ttl                  = 3600
}

// Defines our endpoint as a datasource
resource "aws_appsync_datasource" "wbd_api_datasource" {
  api_id = aws_appsync_graphql_api.wbd_proxy.id
  name   = "MergedAPIendpoint"
  type   = "HTTP"

  http_config {
    endpoint = "https://4ymzt5zsqzhvzkrdwt62x22kgi.appsync-api.us-west-1.amazonaws.com" // For now passing the merged api endpoint from the poc
  }
}

// Creating and referecing our resolvers, you will most likely have multiple of these
resource "aws_appsync_resolver" "listGamesResolver" {
  api_id = aws_appsync_graphql_api.wbd_proxy.id
  type   = "Query"
  field  = "listGames"

  data_source = aws_appsync_datasource.wbd_api_datasource.name
  kind        = "UNIT"

  code = file("resolvers/listGames.js")

  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }

// Enables caching on this specific resolver
  caching_config {
    ttl = 3600
  }

}