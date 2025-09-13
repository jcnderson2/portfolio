variable "name" {
  description = "The name of the resource group"
  type        = string
  default     = "prod-rg-1"
}

variable "location" {
  description = "The Azure location for the resource group"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource group"
  type        = map(string)
  default     = {}
}