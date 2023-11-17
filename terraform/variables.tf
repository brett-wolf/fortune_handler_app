variable "location" {
  type    = string
  default = "eastus"
}

variable "prefix" {
  type    = string
  default = "fortune-handler"
}

variable "admin_email" {
  type    = string
  default = "brett.wolf.howells@gmail.com"
}

variable "function_code" {
  type = string
  default = "../fortune_handler_function"
}