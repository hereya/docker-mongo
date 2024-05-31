terraform {
  required_providers {
    docker = {
      source  = "registry.terraform.io/kreuzwerker/docker"
      version = "3.0.2"
    }

    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "3.6.2"
    }
  }
}

variable "port" {
  default = 27017
}

provider "random" {}
provider "docker" {}

resource "random_pet" "dbname" {}

resource "docker_image" "mongo" {
  name         = "mongo:latest"
  keep_locally = false
}

resource "docker_container" "mongo" {
  image = docker_image.mongo.image_id
  name  = random_pet.dbname.id
  ports {
    internal = 27017
    external = var.port
  }
}

output "MONGO_URL" {
  sensitive   = true
  value       = "mongodb://localhost:${docker_container.mongo.ports[0].external}/${random_pet.dbname.id}"
}

output "MONGO_DBNAME" {
  sensitive   = true
  value       = random_pet.dbname.id
}
