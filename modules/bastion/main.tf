variable "public_subnets" {}
variable "vpc_id" {}

resource "aws_instance" "bastion" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.small"
  subnet_id     = var.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  key_name = "my-key"
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # For testing
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}