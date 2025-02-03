################################################################################
# TERRAFORM ARGOCD MODULE VARIABLES FILE
################################################################################

variable "namespace" {
  description = "The namespace to deploy ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_version" {
  description = "The version of the ArgoCD Helm chart"
  type        = string
  default     = "5.46.8"
}

variable "app_name" {
  description = "The name of the ArgoCD application"
  type        = string
  default     = "my-app"
}

variable "repo_url" {
  description = "The Git repository URL for the application"
  type        = string
  default     = "https://github.com/myorg/myrepo.git"
}

variable "app_path" {
  description = "The path to the application in the Git repository"
  type        = string
  default     = "path/to/app"
}