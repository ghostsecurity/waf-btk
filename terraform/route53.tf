resource "aws_route53_record" "btk" {
  zone_id = var.zone_id
  name    = var.dns_name
  type    = "CNAME"
  ttl     = "300"

  records = [aws_alb.btk.dns_name]
}
