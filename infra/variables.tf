variable "domain_name" {
  description = "Domain name for the website"
  type        = string
  default     = "rafaelmatsumoto.com"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "rafaelmatsumoto.com"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "PersonalWebsite"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

variable "github_organization" {
  description = "GitHub organization/username for OIDC configuration"
  type        = string
  default     = "rafaelmatsumoto"
}

variable "github_repository" {
  description = "GitHub repository name for OIDC configuration"
  type        = string
  default     = "rafaelmatsumoto.com"
}