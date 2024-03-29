variable "ecr_name" {
  description = "The name of the ECR registry"
  type        = any
  default     = "lanchonetedarua"
}

variable "image_mutability" {
  description = "Provide image mutability"
  type        = string
  default     = "IMMUTABLE"
}


variable "encrypt_type" {
  description = "Provide type of encryption here"
  type        = string
  default     = "KMS"
}

variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}

variable "client_key" {
  description = "AKIAU6GD3QJR2EMRVYOR"
}

variable "client_secret" {
  description = "0ZvpUMYON2ldsmnG3TdPn9x6TwByhV6QbohmFq+n"
}