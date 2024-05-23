##PRACTICE WITH TERRAFORM: SECURITY GROUP, APPLICATION LOAD BALANCER, TARGET GROUP, LOAD BALANCER LISTERNER...


##1. Security Group for ALB (Internet -> ALB):

resource "aws_security_group" "alb_sg" {
  name        = "besfort-alb-sg"
  description = "Security Group for Application Load Balancer"
  vpc_id = aws_vpc.custom_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "besfort-alb-sg"
  }
}
------------------------------------------------------------
##1.1 Security Group for EC2 Instances (ALB -> EC2):
resource "aws_security_group" "ecs_sg" {
  name        = "besfort-ecs-sg"
  description = "Security Group for Web Server Instances"
  vpc_id = aws_vpc.custom_vpc.id
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "besfort-ec2-sg"
  }
}
----------------------------------------------------------------------
##2. Application Load Balancer:

resource "aws_lb" "app_lb" {
  name               = "besfort-app-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id
  depends_on         = [aws_internet_gateway.igw_vpc]
}
-------------------------------------------------------------
##3. Target Group for ALB:

resource "aws_lb_target_group" "alb_ecs_tg" {
  name     = "besfort-web-server-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.custom_vpc.id
  tags = {
    Name = "besfort-alb_ecs_tg"
  }
}

resource "aws_lb_target_group" "besfort-tg" {
  name        = "besfort-tg"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.custom_vpc.id
}

------------------------------------------------------------------
##3.1 ALB LISTENER:

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_ecs_tg.arn
  }
  tags = {
    Name = "ecs-alb-listener"
  }
}
--------------------------------------------------------------------