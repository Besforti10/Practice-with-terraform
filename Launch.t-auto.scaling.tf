##PRACTICE WITH TERRAFORM: LAUNCH TEMPLATE, AUTO-SCALING 

##1. Launch Template:

resource "aws_launch_template" "ecs_launch_template" {
  name = "besfort-web-server"
  image_id      = "ami-0bb84b8ffd87024d8"
  instance_type = "t2.micro"
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ecs_sg.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "static-web"
    }
  }
}
----------------------------------------------------------------------

##2. Auto-scaling:

resource "aws_autoscaling_group" "ecs_asg" {  
  name                = "static-web-as"
  desired_capacity    = 2  
  min_size            = 2
  max_size            = 3
  target_group_arns   = [aws_lb_target_group.alb_ecs_tg.arn]
  vpc_zone_identifier = aws_subnet.private_subnet[*].id
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }
}
output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}
--------------------------------------------------------------------------------
