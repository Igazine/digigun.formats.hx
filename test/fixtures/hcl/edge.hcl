# top-level comment
variable "image_name" {
  default = "digigun-base"
  description = <<EOF
line one
line two
EOF
  tags = ["base", "stable"]
  metadata = {
    owner = "digigun"
    active = true
  }
}
