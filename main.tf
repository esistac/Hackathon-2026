terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {}

# 1. Réseau privé virtuel pour isoler l'architecture
resource "docker_network" "streaming_net" {
  name = "network_zero_trust"
}

# 2. Conteneur pour le Serveur de Clés Éphémères
resource "docker_container" "key_server" {
  name  = "serveur_de_cles"
  image = "mon-serveur-de-cles:latest"
  networks_advanced {
    name = docker_network.streaming_net.name
  }
  ports {
    internal = 8080
    external = 8085
  }
  # Injection sécurisée de la clé AES générée localement
  volumes {
    host_path      = "${path.cwd}/enc.key"
    container_path = "/app/secrets/enc.key"
  }
}

# 3. Conteneur pour le Serveur de Diffusion Vidéo (Nginx)
resource "docker_container" "video_server" {
  name  = "serveur_video_nginx"
  image = "nginx:alpine"
  networks_advanced {
    name = docker_network.streaming_net.name
  }
  ports {
    internal = 80
    external = 8000
  }
  
  # Liens vers la configuration et les segments de vidéos chiffrés
  volumes {
    host_path      = "${path.cwd}/nginx.conf"
    container_path = "/etc/nginx/conf.d/default.conf"
  }
  volumes {
    host_path      = "${path.cwd}/output"
    container_path = "/usr/share/nginx/html/video"
  }
}