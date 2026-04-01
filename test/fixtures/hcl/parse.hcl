source "amazon-ebs" "example" {
  ami_name = "example-ami"
  tags = ["base", "golden"]
}

build {
  sources = ["source.amazon-ebs.example"]
  description = <<EOF
This is a long description.
Over two lines.
EOF
}
