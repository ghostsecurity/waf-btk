output "instance_ip" {
  value = aws_instance.btk.public_ip
}

output "alb_cname" {
  value = aws_alb.btk.dns_name
}
