resource "aws_launch_configuration" "nginx_lc" {
  name            = "nginx-launch-config"
  image_id        = "ami-0230bd60aa48260c6"
  instance_type   = "t2.micro"
  security_groups =  [aws_security_group.nginx-sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              yum install -y nginx
              systemctl enable nginx
              systemctl start nginx
              EOF

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nginx_asg" {   
  name                 = "nginx-asg"
  launch_configuration = aws_launch_configuration.nginx_lc.id
  vpc_zone_identifier  = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

  target_group_arns    = [aws_alb_target_group.nginx_tg.arn]
  health_check_type    = "Ealb"
  desired_capacity     = 2
  min_size             = 1
  max_size             = 4

  tag {
    key                 = "Name"
    value               = "nginx"
    propagate_at_launch = true
  }
}



resource "aws_alb" "nginx_alb" {
  name               = "nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_alb.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

  enable_deletion_protection = false
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.nginx_alb.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.nginx_tg.arn
  }
}

resource "aws_security_group" "nginx_alb" {
  name = "nginx_alb"

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_alb_target_group" "nginx_tg" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


