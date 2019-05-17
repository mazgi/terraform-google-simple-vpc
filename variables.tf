variable "basename" {
  type = "string"
}

variable "cidr_blocks_subnetworks" {
  type = "map"

  default = {
    "10.0.0.0/16" = "us-central1"
  }
}

variable "flow_sampling" {
  default = 0.5
}

variable "cidr_blocks_allow_ssh" {
  type = "list"

  default = [
    "127.0.0.0/8", # disabled
  ]
}

variable "cidr_blocks_allow_http" {
  type = "list"

  default = [
    "0.0.0.0/0",
  ]
}
