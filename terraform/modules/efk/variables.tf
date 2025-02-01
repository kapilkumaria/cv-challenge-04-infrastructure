################################################################################
# TERRAFORM EFK MODULE VARIABLES FILE
################################################################################

variable "namespace" {
  description = "The namespace to deploy EFK stack"
  type        = string
  default     = "logging"
}

variable "elasticsearch_version" {
  description = "The version of the Elasticsearch Helm chart"
  type        = string
  default     = "7.10.0"
}

variable "fluentd_version" {
  description = "The version of the Fluentd Helm chart"
  type        = string
  default     = "0.3.1"
}

variable "kibana_version" {
  description = "The version of the Kibana Helm chart"
  type        = string
  default     = "7.10.0"
}