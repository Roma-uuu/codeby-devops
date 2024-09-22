terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.70"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yandex_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
}

resource "yandex_vpc_network" "my_network" {
  name = "my-network"
}

resource "yandex_vpc_subnet" "public_subnet" {
  name           = "public-subnet"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.my_network.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

resource "yandex_vpc_subnet" "private_subnet" {
  name           = "private-subnet"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.my_network.id
  v4_cidr_blocks = ["10.0.1.0/24"]
  route_table_id = yandex_vpc_route_table.my_route_table.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name      = "nat-gateway"
  folder_id = var.yandex_folder_id

  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "my_route_table" {
  name       = "my-route-table"
  network_id = yandex_vpc_network.my_network.id
  folder_id  = var.yandex_folder_id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_compute_instance" "public" {
  name        = "public"
  platform_id = "standard-v1"
  zone        = var.default_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd808e721rc1vt7jkd0o" # Ubuntu 20.04 LTS
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  provisioner "file" {
    source      = var.ssh_private_key_path
    destination = "/home/ubuntu/id_rsa"
    connection {
      type        = "ssh"
      host        = self.network_interface[0].nat_ip_address
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "file" {
    source      = var.ssh_public_key_path
    destination = "/home/ubuntu/id_rsa.pub"
    connection {
      type        = "ssh"
      host        = self.network_interface[0].nat_ip_address
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/id_rsa",
      "ssh-keyscan -H ${yandex_compute_instance.private.network_interface.0.ip_address} >> ~/.ssh/known_hosts",
    ]
    connection {
      type        = "ssh"
      host        = self.network_interface[0].nat_ip_address
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }
}

resource "yandex_compute_instance" "private" {
  name        = "private"
  platform_id = "standard-v1"
  zone        = var.default_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd808e721rc1vt7jkd0o" # Ubuntu 20.04 LTS
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_subnet.id
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

resource "null_resource" "configure_private" {
  depends_on = [yandex_compute_instance.public, yandex_compute_instance.private]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "echo 'server { listen 8080 default_server; listen [::]:8080 default_server; location / { root /var/www/html; index index.html; } }' | sudo tee /etc/nginx/sites-available/default",
      "sudo systemctl restart nginx",
      "sudo ufw allow 8080",
      "sudo ufw allow ssh",
      "sudo ufw --force enable"
    ]
    connection {
      type                = "ssh"
      host                = yandex_compute_instance.private.network_interface[0].ip_address
      user                = "ubuntu"
      private_key         = file(var.ssh_private_key_path)
      bastion_host        = yandex_compute_instance.public.network_interface[0].nat_ip_address
      bastion_user        = "ubuntu"
      bastion_private_key = file(var.ssh_private_key_path)
    }
  }
}

resource "yandex_vpc_security_group" "public_sg" {
  name        = "public-sg"
  network_id  = yandex_vpc_network.my_network.id
  description = "Security group for public instance"

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "private_sg" {
  name        = "private-sg"
  network_id  = yandex_vpc_network.my_network.id
  description = "Security group for private instance"

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["10.0.0.0/24"]
  }

  ingress {
    protocol       = "TCP"
    port           = 8080
    v4_cidr_blocks = ["10.0.0.0/24"]
  }
}

output "private_instance_ip" {
  value = yandex_compute_instance.private.network_interface[0].ip_address
}

resource "yandex_compute_instance" "imported_instance" {
  name        = "compute-vm"
  platform_id = "standard-v1"
  zone        = "ru-central1-d"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8ldm3oj8nl1n1ig6h0"  # Ubuntu 24.04 LTS
    }
  }
  network_interface {
    subnet_id = "default"
    nat       = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}