variable "basename" {
  type = string
}

variable "cidr_blocks_subnetworks" {
  type = map(string)

  default = {
    "10.0.0.0/16" = "us-central1"
  }
}

variable "flow_sampling" {
  type = number

  default = 0.5
}

variable "cidr_blocks_allow_ssh" {
  type = list(string)

  default = [
    "127.0.0.0/8", # disabled
  ]
}

variable "cidr_blocks_allow_http" {
  type = list(string)

  default = [
    "0.0.0.0/0",
  ]
}
