## General vars
variable "name" {
  description = "This name will prefix all resources, and be added as the value for the 'Name' tag where supported"
  type        = string
  default     = "aws-patching-monitoring"
}

variable "envname" {
  description = "This label will be added after 'name' on all resources, and be added as the value for the 'Environment' tag where supported"
  type        = string
  default     = "dev"
}

variable "envtype" {
  description = "This label will be added after 'envname' on all resources, and be added as the value for the 'Envtype' tag where supported"
  type        = string
  default     = "cloudfortecmp"
}

variable "profile" {
  description = "This label will be added to the SSM baseline description"
  type        = string
  default     = "Linux-Windows"
}

## Maintenance window vars
variable "scan_maintenance_window_schedule" {
  description = "The schedule of the scan Maintenance Window in the form of a cron or rate expression"
  type        = string
  default     = "cron(0 2 L * ? *)"
}

variable "install_maintenance_window_schedule" {
  description = "The schedule of the install Maintenance Window in the form of a cron or rate expression"
  type        = string
  default     = "cron(0 2 L * ? *)"
}

variable "maintenance_window_duration" {
  description = "The duration of the maintenence windows (hours)"
  type        = string
  default     = "3"
}

variable "maintenance_window_cutoff" {
  description = "The number of hours before the end of the Maintenance Window that Systems Manager stops scheduling new tasks for execution"
  type        = string
  default     = "1"
}

variable "scan_patch_groups" {
  description = "The list of scan patching groups, one target will be created per entry in this list"
  type        = "list"
  default     = ["ProductionLinux", "ProductionWindows"]
}

variable "install_patch_groups" {
  description = "The list of install patching groups, one target will be created per entry in this list"
  type        = "list"
  default     = ["ProductionLinux", "ProductionWindows"]
}

variable "max_concurrency" {
  description = "The maximum amount of concurrent instances of a task that will be executed in parallel"
  type        = string
  default     = "20"
}

variable "max_errors" {
  description = "The maximum amount of errors that instances of a task will tollerate before being de-scheduled"
  type        = string
  default     = "50"
}

## logging info
variable "s3_bucket_name" {
  description = "The name of the S3 bucket to create for log storage"
  type        = string
  default     = "ssmlogs"
}

variable "aws_region" {
  description = "The AWS region to create this SSM resource in"
  type        = string
  default     = "ap-south-1"
}

variable "aws_access_key" {
  description = "The AWS region to create this SSM resource in"
  type        = string
}

variable "aws_secret_access_key" {
  description = "The AWS region to create this SSM resource in"
  type        = string
}
