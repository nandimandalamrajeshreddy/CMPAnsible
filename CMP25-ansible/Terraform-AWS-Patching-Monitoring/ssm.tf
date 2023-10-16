resource "aws_ssm_maintenance_window" "install_window" {
  name     = "${var.name}-${var.envname}-patch-maintenance-install-mw"
  schedule = var.install_maintenance_window_schedule
  duration = var.maintenance_window_duration
  cutoff   = var.maintenance_window_cutoff
}

resource "aws_ssm_maintenance_window_target" "target_install" {
  window_id     = aws_ssm_maintenance_window.install_window.id
  resource_type = "INSTANCE"

  targets {
    key = "tag:CMP_PATCH"
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    values = var.install_patch_groups
  }
}

resource "aws_ssm_maintenance_window_task" "task_install_patches" {
  window_id        = aws_ssm_maintenance_window.install_window.id
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = aws_iam_role.ssm_maintenance_window.arn
  max_concurrency  = var.max_concurrency
  max_errors       = var.max_errors

  targets {
    key    = "WindowTargetIds"
    values = aws_ssm_maintenance_window_target.target_install.*.id
  }

  task_parameters {
    name   = "Operation"
    values = ["Install"]
  }

  logging_info {
    s3_bucket_name = aws_s3_bucket.ssm_patch_log_bucket.id
    s3_region      = var.aws_region
  }
}

resource "aws_sns_topic" "CloudWatchAlarm" {
  name = "Default_CloudWatch_Alarms_Topic"
}

resource "aws_ssm_parameter" "AmazonCloudWatch-windows" {
  name  = "AmazonCloudWatch-windows"
  type  = "String"
  value = <<VALUE
  {
	"logs": {
		"logs_collected": {
			"files": {
				"collect_list": [
					{
						"file_path": "C:\\Users\\cmpadmin\\Documents\\*.log",
						"log_group_name": "IISLogs",
						"log_stream_name": "{instance_id}"
					}
				]
			},
			"windows_events": {
				"collect_list": [
					{
						"event_format": "xml",
						"event_levels": [
							"VERBOSE",
							"INFORMATION",
							"WARNING",
							"ERROR",
							"CRITICAL"
						],
						"event_name": "System",
						"log_group_name": "WindowsSystemEvents",
						"log_stream_name": "{instance_id}"
					}
				]
			}
		}
	},
	"metrics": {
		"append_dimensions": {
			"AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
			"ImageId": "$${aws:ImageId}",
			"InstanceId": "$${aws:InstanceId}",
			"InstanceType": "$${aws:InstanceType}"
		},
		"metrics_collected": {
			"LogicalDisk": {
				"measurement": [
					"% Free Space"
				],
				"metrics_collection_interval": 60,
				"resources": [
					"*"
				]
			},
			"Memory": {
				"measurement": [
					"% Committed Bytes In Use"
				],
				"metrics_collection_interval": 60
			},
			"Paging File": {
				"measurement": [
					"% Usage"
				],
				"metrics_collection_interval": 60,
				"resources": [
					"*"
				]
			},
			"PhysicalDisk": {
				"measurement": [
					"% Disk Time"
				],
				"metrics_collection_interval": 60,
				"resources": [
					"*"
				]
			},
			"Processor": {
				"measurement": [
					"% User Time",
					"% Idle Time",
					"% Interrupt Time"
				],
				"metrics_collection_interval": 60,
				"resources": [
					"*"
				]
			}
		}
	}
}
VALUE
}