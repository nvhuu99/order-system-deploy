resource "aws_autoscaling_policy" "general_node_group_cpu_target" {
  name                      = "${aws_eks_cluster.main.name}_general_ng_cpu_target"
  autoscaling_group_name    = aws_eks_node_group.general.resources[0].autoscaling_groups[0].name
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 60

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 90.0
  }
}

resource "aws_autoscaling_policy" "general_node_group_memory_target" {
  name                   = "${aws_eks_cluster.main.name}_general_ng_cpu_target"
  autoscaling_group_name = aws_eks_node_group.general.resources[0].autoscaling_groups[0].name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    customized_metric_specification {
      metric_name = "mem_used_percent"
      namespace   = "CWAgent"
      statistic   = "Average"
      metric_dimension {
        name  = "AutoScalingGroupName"
        value = aws_eks_node_group.general.resources[0].autoscaling_groups[0].name
      }
    }
    target_value = 80
  }
}