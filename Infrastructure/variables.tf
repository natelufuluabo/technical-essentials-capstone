variable "vpc_name" {
  description = "Value of the name tag for the VPC"
  type        = string
  default     = "main_vpc"
}

variable "public_subnet_name_1" {
  description = "Value of the name tag for the public subnet 1"
  type        = string
  default     = "public_subnet_1"
}

variable "public_subnet_name_2" {
  description = "Value of the name tag for the public subnet 2"
  type        = string
  default     = "public_subnet_2"
}

variable "private_subnet_name_1" {
  description = "Value of the name tag for the private subnet 1"
  type        = string
  default     = "private_subnet_name_1"
}

variable "private_subnet_name_2" {
  description = "Value of the name tag for the private subnet 2"
  type        = string
  default     = "private_subnet_name_2"
}

variable "private_subnet_name_3" {
  description = "Value of the name tag for the private subnet 3"
  type        = string
  default     = "private_subnet_name_3"
}

variable "private_subnet_name_4" {
  description = "Value of the name tag for the private subnet 4"
  type        = string
  default     = "private_subnet_name_4"
}

variable "internet_gw_name" {
  description = "Value of the name tag for the internet gw"
  type        = string
  default     = "internet_gw"
}

variable "availability_zone_1" {
  description = "Value of the name tag for the availability zone 1"
  type        = string
  default     = "ca-central-1a"
}

variable "availability_zone_2" {
  description = "Value of the name tag for the availability zone 2"
  type        = string
  default     = "ca-central-1b"
}