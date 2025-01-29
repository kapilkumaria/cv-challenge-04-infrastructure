variable "namespace" {
  description = "The namespace to deploy ArgoCD"
  default     = "argocd"
}

variable "app_name" {
  description = "The name of the ArgoCD application"
  default     = "my-app"
}

variable "repo_url" {
  description = "The Git repository URL for the application"
  default     = "https://github.com/myorg/myrepo.git"
}

variable "app_path" {
  description = "The path to the application in the Git repository"
  default     = "path/to/app"
}