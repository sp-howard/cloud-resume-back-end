################# Route53 ##################

# Create Host Zone
resource "aws_route53_zone" "main" {
  name = var.domain_name
}

# A record to Cloudfront alias
resource "aws_route53_record" "www-a" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  #Cloudfront Endpoint
  alias {
    name                   = aws_cloudfront_distribution.www_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.www_s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }

}

# Redirect WWW to Root
resource "aws_route53_record" "redirect" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www"
  type    = "A"

  # Redirect S3 Bucket
  alias {
    name                   = "${aws_s3_bucket.redirect_bucket.website_domain}"
    zone_id                = "${aws_s3_bucket.redirect_bucket.hosted_zone_id}"
    evaluate_target_health = false
  }

}

# Viewcount API
resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api"
  type    = "A"

  # API Gateway Domain Name
  alias {
    name                   = "${aws_api_gateway_domain_name.api-domain.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.api-domain.cloudfront_zone_id}"
    evaluate_target_health = false
  }

}

# Replace registered domain's name servers
resource "aws_route53domains_registered_domain" "domain" {
  domain_name = var.domain_name

  name_server {
    name = aws_route53_zone.main.name_servers[0]
  }
  name_server {
    name = aws_route53_zone.main.name_servers[1]
  }
  name_server {
    name = aws_route53_zone.main.name_servers[2]
  }
  name_server {
    name = aws_route53_zone.main.name_servers[3]
  }
}

# Add DNS records for ACM certificate validation
resource "aws_route53_record" "main" {
  for_each = {
    for dvo in aws_acm_certificate.ssl_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
} 

