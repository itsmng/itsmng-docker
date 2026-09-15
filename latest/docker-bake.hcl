# Definition de build partagee entre le poste de dev et la CI :
#   docker buildx bake                 image locale (plateforme courante)
#   docker buildx bake release         multi-arch, pousse
#   docker buildx bake --set itsmng.args.ITSMNG_PLUGINS="formcreator pdf"
variable "REGISTRY" { default = "ghcr.io/itsmng" }
variable "IMAGE" { default = "itsm-ng" }
variable "VERSION" { default = "dev" }
# Plugins compiles dans l'image (liste separee par des espaces).
variable "ITSMNG_PLUGINS" { default = "" }
# Version exacte du paquet Debian itsm-ng ; vide = derniere du depot.
variable "ITSMNG_APT_VERSION" { default = "" }

target "itsmng" {
  context    = "."
  dockerfile = "Dockerfile"
  tags       = ["${REGISTRY}/${IMAGE}:${VERSION}"]
  args = {
    VERSION            = VERSION
    ITSMNG_PLUGINS     = ITSMNG_PLUGINS
    ITSMNG_APT_VERSION = ITSMNG_APT_VERSION
  }
}

target "release" {
  inherits   = ["itsmng"]
  platforms  = ["linux/amd64", "linux/arm64"]
  tags       = ["${REGISTRY}/${IMAGE}:${VERSION}", "${REGISTRY}/${IMAGE}:latest"]
  # Attestations SLSA + SBOM attachees a l'image.
  attest = [
    "type=provenance,mode=max",
    "type=sbom",
  ]
}

group "default" { targets = ["itsmng"] }
