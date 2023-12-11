resource "aws_security_group" "nginx-sg" {
  name        = "nginx-sg"
  description = "Allow inbound traffic on tcp/80 & SSH 22"
  vpc_id      = aws_vpc.main.id  # Update the VPC reference

  ingress {
    description     = "Allow 80 from the ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx_lb.id]  # Update this line
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "web_server"
    Purpose = "Manage inbound traffic"
  }
}
