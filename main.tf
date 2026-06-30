terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {}

# 1. Création du réseau privé pour isoler nos conteneurs
resource "docker_network" "streaming_net" {
  name = "network_zero_trust"
}

# 2. Build et déploiement du conteneur Key-Server
resource "docker_image" "key_server_img" {
  name = "mon-serveur-de-cles:latest"
  keep_locally = true
}

resource "docker_container" "key_server" {
  name  = "key-server"
  image = docker_image.key_server_img.image_id
  
  networks_advanced {
    name = docker_network.streaming_net.name
  }

  ports {
    internal = 8080
    external = 8080
  }

  # On injecte la clé générée en local directement dans le conteneur
  volumes {
    host_path      = "${path.cwd}/enc.key"
    container_path = "/app/enc.key"
  }
}

# 3. Déploiement du conteneur Nginx (Le CDN local)
resource "docker_container" "nginx_cdn" {
  name  = "nginx-cdn"
  image = "nginx:alpine"
  
  networks_advanced {
    name = docker_network.streaming_net.name
  }

  ports {
    internal = 80
    external = 8000
  }

  # Montage de la configuration Nginx
  volumes {
    host_path      = "${path.cwd}/nginx.conf"
    container_path = "/etc/nginx/nginx.conf"
  }

  # Montage des fichiers vidéos chiffrés (générés dans output/ par ffmpeg)
  volumes {
    host_path      = "${path.cwd}/output"
    container_path = "/usr/share/nginx/html/video"
  }

  depends_on = [docker_container.key_server]
}