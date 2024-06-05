# Defining CIDR Block for VPC
variable "vpc_cidr" {
  default = "20.0.0.0/16"
}
# Defining CIDR Block for 1st Subnet
variable "subnet1_cidr" {
  default = "20.0.1.0/24"
}
# Defining CIDR Block for 2nd Subnet
variable "subnet2_cidr" {
  default = "20.0.2.0/24"
}
# Defining CIDR Block for 3rd Subnet
variable "subnet3_cidr" {
  default = "20.0.3.0/24"
}
# Defining CIDR Block for 4th Subnet
variable "subnet4_cidr" {
  default = "20.0.4.0/24"
}
