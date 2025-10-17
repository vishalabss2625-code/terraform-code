# Output values for EC2 cluster

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.cluster_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.cluster_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "security_group_id" {
  description = "ID of the cluster security group"
  value       = aws_security_group.cluster_sg.id
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.cluster_lb.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.cluster_lb.zone_id
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.cluster_lb.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.cluster_tg.arn
}

output "auto_scaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.cluster_asg.name
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.cluster_template.id
}

output "key_pair_name" {
  description = "Name of the key pair used"
  value       = var.key_pair_name != "" ? var.key_pair_name : aws_key_pair.cluster_key_pair[0].key_name
}

output "cluster_url" {
  description = "URL to access the cluster"
  value       = "http://${aws_lb.cluster_lb.dns_name}"
}

# Instructions for managing the cluster
output "cluster_management_instructions" {
  description = "Instructions for managing the EC2 cluster"
  value = <<-EOT
    Your EC2 cluster has been created successfully!
    
    Access your cluster:
    - Load Balancer URL: http://${aws_lb.cluster_lb.dns_name}
    - Application Port: ${var.app_port}
    
    Manage instances:
    1. List instances: aws ec2 describe-instances --filters "Name=tag:Name,Values=${var.cluster_name}-instance"
    2. Scale cluster: aws autoscaling set-desired-capacity --auto-scaling-group-name ${aws_autoscaling_group.cluster_asg.name} --desired-capacity <number>
    
    Connect to instances:
    - Via SSH: ssh -i ~/.ssh/${var.key_pair_name != "" ? var.key_pair_name : "${var.cluster_name}-key-pair"}.pem ec2-user@<instance-ip>
    - Via SSM: aws ssm start-session --target <instance-id>
    
    Monitor:
    - Check CloudWatch metrics for namespace: ${var.cluster_name}
    - View logs in CloudWatch Log Groups: ${var.cluster_name}-system-logs and ${var.cluster_name}-app-logs
  EOT
}