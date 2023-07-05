resource "aws_instance" "btk" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = element(aws_subnet.btk-public.*.id, 0)
  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.internal.id,
    aws_security_group.external.id,
  ]
  user_data = <<-EOF
#!/bin/bash

# Enable GatewayPorts
sed -i 's/^#GatewayPorts no$/GatewayPorts yes/' /etc/ssh/sshd_config

# Restart sshd
systemctl restart sshd
EOF

  tags = {
    Name        = "${var.app}-ec2"
    Environment = var.environment
  }

}

resource "aws_alb_target_group_attachment" "btk" {
  target_group_arn = aws_lb_target_group.btk.arn
  target_id        = aws_instance.btk.id
  port             = 5000
}
