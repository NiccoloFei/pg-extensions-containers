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

variable "extension_name" {
  default = "placeholder"
}

variable "extension_versions" {
  type = list(string)
  default = ["placeholder"]
}

fullname = ( environment == "testing") ? "${registry}/${extension_name}-testing" : "${registry}/${extension_name}"
now = timestamp()


target "default" {
  matrix = {
    pgVersion = [
      "18"
    ]
    distro = [
        "trixie",
        "bookworm"
    ]
    ext_version = extension_versions
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  dockerfile = "Dockerfile"
  name = "${extension_name}-${pgVersion}-${replace(ext_version, ".", "-")}-${distro}"
  tags = [
    "${getImageName(fullname)}:${pgVersion}-${ext_version}-${distro}",
  ]
  context = "${extension_name}/"
  args = {
    PG_MAJOR = "${getMajor(pgVersion)}"
    EXT_VERSION = "${ext_version}"
    BASE = "ghcr.io/cloudnative-pg/postgresql:${pgVersion}-minimal-${distro}"
  }
}

function getMajor {
    params = [ version ]
    result = regex("^([0-9]+)", version)[0]
}

function getImageName {
  params = [ name ]
  result = lower(name)
}
