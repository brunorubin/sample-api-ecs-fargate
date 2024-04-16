variable "AWS_REGION" {
  default = "us-east-1"
}

variable "project" {
  default = "sample"
}

variable "environment" {
  default = "sandbox"
}

variable "api_image" {
  default = "brunorubin/genratrapi"
}

variable "container_port" {
    default = "8080"
}

variable "scale_min" {
  default = "3"
}

variable "scale_max" {
  default = "6"
}