variable "environment" {
  default = "testing"
  validation {
    condition = contains(["testing", "production"], environment)
    error_message = "environment must be either testing or production"
  }
}

variable "registry" {
  default = "localhost:5000"
}

variable "extension" {
  default = "pgvector"
}

variable "extension_version" {
  default = "master"
}

variable "platform_suffix" {
  default = ""
}

fullname = ( environment == "testing") ? "${registry}/${extension}-testing" : "${registry}/${extension}"
now = timestamp()


target "default" {
  matrix = {
    pgVersion = [
      "18beta1"
    ]
    distro = [
        "bookworm",
        "bullseye"
    ]
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  dockerfile = "Dockerfile"
  name = "${extension}-${pgVersion}-${extension_version}-${distro}"
  tags = [
    "${getImageName(fullname)}:${pgVersion}-${extension_version}-${distro}${platform_suffix}",
  ]
  context = "${extension}/"
  args = {
    PG_MAJOR = "${getMajor(pgVersion)}"
    EXT_VERSION = "${extension_version}"
    BASE = "ghcr.io/cloudnative-pg/postgresql:${pgVersion}-minimal-${distro}"
  }
}

function getMajor {
    params = [ version ]
    result = index(split("beta", version),0)
}

function getImageName {
  params = [ name ]
  result = lower(name)
}
