# EC2 cluster resources (cleaned and single HCL file)

# Key Pair (if specified)
resource "aws_key_pair" "cluster_key_pair" {
  count = var.key_pair_name != "" ? 0 : 1

  key_name   = "${var.cluster_name}-key-pair"
  public_key = file("~/.ssh/id_rsa.pub") # You need to generate this key pair locally

  tags = var.tags
}

# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.cluster_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })

  tags = var.tags
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.cluster_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = var.tags
}

# IAM Policy for EC2 instances (CloudWatch, SSM access)
resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.cluster_name}-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "ssm:ListCommands"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach AWS managed SSM policy to the role (so instances can be managed via SSM)
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Launch Template
resource "aws_launch_template" "cluster_template" {
  name_prefix   = "${var.cluster_name}-template"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name != "" ? var.key_pair_name : (length(aws_key_pair.cluster_key_pair) > 0 ? aws_key_pair.cluster_key_pair[0].key_name : "")

  vpc_security_group_ids = [aws_security_group.cluster_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = var.cluster_name
    app_port     = var.app_port
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.cluster_name}-instance"
    })
  }

  tags = var.tags
}

# Auto Scaling Group
resource "aws_autoscaling_group" "cluster_asg" {
  name                      = "${var.cluster_name}-asg"
  vpc_zone_identifier       = aws_subnet.public_subnets[*].id
  target_group_arns         = [aws_lb_target_group.cluster_tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.cluster_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Application Load Balancer
resource "aws_lb" "cluster_lb" {
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.cluster_sg.id]
  subnets            = aws_subnet.public_subnets[*].id

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-alb"
  })
}

# Target Group
resource "aws_lb_target_group" "cluster_tg" {
  name     = "${var.cluster_name}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.cluster_vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-target-group"
  })
}

# Load Balancer Listener
resource "aws_lb_listener" "cluster_listener" {
  load_balancer_arn = aws_lb.cluster_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cluster_tg.arn
  }

  tags = var.tags
}
