resource "aws_s3_bucket" "test_bucket" {
  bucket = "my-bucket"
}

# data "aws_canonical_user_id" "log-delivery-user-id" {}

module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"

  aliases         = ["cdn.example.com"]
  http_version    = "http2and3"
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  create_monitoring_subscription = false
  create_origin_access_control   = true
  create_origin_access_identity  = false

  origin_access_control = {
    user_avatars = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }
  origin = {
    user_avatars = {
      domain_name           = aws_s3_bucket.test_bucket.bucket_domain_name
      origin_access_control = "user_avatars"
    }
  }

  default_cache_behavior = {
    target_origin_id           = "user_avatars"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    query_string               = true
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
  }
}
