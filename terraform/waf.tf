resource "aws_wafv2_web_acl" "block" {
  name        = "waf-btk-block-rule"
  description = "Test to block malicious request payloads"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "waf-btk-allow"
    sampled_requests_enabled   = false
  }

  custom_response_body {
    key          = "btk-block"
    content_type = "APPLICATION_JSON"
    content      = "{\"message\":\"Blocked by WAF\"}"
  }

  rule {
    name     = "btk-block-malicious"
    priority = 0

    action {
      block {
        custom_response {
          response_code            = "418"
          custom_response_body_key = "btk-block"
        }
      }
    }

    statement {
      byte_match_statement {
        field_to_match {
          body {}
        }

        positional_constraint = "CONTAINS"
        search_string         = "from schema"

        text_transformation {
          priority = 0
          type     = "LOWERCASE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "waf-btk-block"
      sampled_requests_enabled   = false
    }
  }
}

resource "aws_wafv2_web_acl_association" "btk" {
  resource_arn = aws_alb.btk.arn
  web_acl_arn  = aws_wafv2_web_acl.block.arn
}
