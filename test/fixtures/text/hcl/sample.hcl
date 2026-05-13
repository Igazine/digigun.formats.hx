packer {
  required_version = ">= 1.10.0"
}

source "amazon-ebs" "base" {
  ami_name = "digigun-base"
  instance_type = "t3.micro"
  tags = {
    Owner = "digigun"
    Project = "formats"
  }
}

build {
  name = "base-image"
  sources = ["source.amazon-ebs.base"]
}
