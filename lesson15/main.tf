module "data_subnet" {
  source = "./data_subnet"
  token  = var.yandex_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  vpc_id    = var.vpc_id
}

locals {
  selected_subnet_id = lookup(module.data_subnet.subnets_info, var.default_zone, [])[0]
}

module "vm" {
  source = "./vm"
  yandex_token = var.yandex_token
  yandex_cloud_id = var.yandex_cloud_id
  yandex_folder_id = var.yandex_folder_id
  subnet_id = local.selected_subnet_id
  zone = var.default_zone
  ssh_public_key_path = var.ssh_public_key_path
  ssh_private_key_path = var.ssh_private_key_path
}