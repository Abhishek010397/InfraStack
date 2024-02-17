variable "instance_role_name" {
  type = string
  default = ""
}

variable "instance_policy_arn" {
  type = list(string)
}

variable "instance_profile_role_name" {
  type = string
  default = ""
}
variable "tags" {
  type        = map(string)
  description = "Tags for EC2 IAM Instance Profile Role"
}