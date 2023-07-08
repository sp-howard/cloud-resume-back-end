################# Route53 #################

resource "aws_route53_zone" "main" {
  name = var.domain_name
}

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

  # S3 Endpoint for testing
  /* alias {
    name                   = "s3-website-us-west-2.amazonaws.com"
    zone_id                = aws_s3_bucket.www_bucket.hosted_zone_id
    evaluate_target_health = false
  } */
}

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

/* depends_on = [output.route53_ns] */


# For ACM certificate validation
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