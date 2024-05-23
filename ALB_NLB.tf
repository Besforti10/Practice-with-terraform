##PRACTICE WITH TERRAFORM: APPLICATION LOAD BALANCER, NETWORK LOAD BALANCER


##1. Application Load Balancer:

resource "aws_lb" "app_lb" {
  name               = "task2-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = ["sg-033e9d2d1d88a69dd"]
  subnets            = ["subnet-05d3c997b5b05307e", "subnet-0496fba944166dd21"]
  depends_on         = [aws_internet_gateway.igw_vpc]
}

##1.1 Application Load Balancer Listener:

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:620453548539:targetgroup/task2-tg/132d47c3422a214d"
  }
  tags = {
    Name = "task2-alb-listener"
  }
}
----------------------------------------------------------------------------------------------------------------

##2. Network Load Balancer:
resource "aws_lb" "nlb" { 
  name               = "app-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["subnet-0496fba944166dd21"]
}

##2.1 Network Load Balancer Listener:

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type = "forward"
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:620453548539:targetgroup/nlb-tg/a975c3facac242f7"
  }
    tags = {
    Name = "task2-nlb-listener"
}
}