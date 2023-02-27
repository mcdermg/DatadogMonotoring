variable "datadog_api_key" {
  description = "DataDog API key"
  type        = string
}

variable "datadog_app_key" {
  description = "DataDog app key"
  type        = string
}

variable "api_url" {
  description = "DataDog api_url"
  type        = string
  default     = "https://app.datadoghq.com/"
}
