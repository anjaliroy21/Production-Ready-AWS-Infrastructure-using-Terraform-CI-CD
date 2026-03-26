resource "aws_launch_template" "app" {
  image_id = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.small"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<-EOF
#!/bin/bash
apt update -y
apt install nginx -y
systemctl enable nginx
systemctl start nginx
echo "<h1>Server is working</h1>" > /var/www/html/index.html
EOF
)
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity = 1
  max_size = 1
  min_size = 1

//  vpc_zone_identifier = var.public_subnets
  vpc_zone_identifier = var.private_subnets

  target_group_arns = [var.target_group_arn]

  launch_template {
    id = aws_launch_template.app.id
    version = "$Latest"
  }
}

resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]  # VERY IMPORTANT
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # bastion access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

