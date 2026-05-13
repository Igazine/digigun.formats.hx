source "amazon-ebs" "example" {
  ami_name = "example-ami"
  instance_count = 2
  metadata = {
    owner = "digigun"
  }
}

build {
  sources = ["source.amazon-ebs.example"]
}
