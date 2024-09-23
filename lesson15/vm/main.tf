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

variable "yandex_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
}

variable "yandex_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yandex_folder_id" {
  description = "Yandex Folder ID"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key"
  type        = string
}

resource "yandex_compute_instance" "vm_instance" {
  name        = "vm-instance"
  platform_id = "standard-v1"
  zone        = var.zone

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
    subnet_id = var.subnet_id
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
      "ssh-keyscan -H ${self.network_interface[0].nat_ip_address} >> ~/.ssh/known_hosts",
    ]
    connection {
      type        = "ssh"
      host        = self.network_interface[0].nat_ip_address
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }
}

output "vm_instance_ip" {
  value = yandex_compute_instance.vm_instance.network_interface[0].nat_ip_address
}