resource "linode_instance" "instances" {
    count = var.number_instances

    label = "${var.instance_group}-${count.index}"
    image = var.instance_image
    region = element(var.instance_regions, count.index)
    type = var.instance_type
    root_pass = var.instance_root_password
    authorized_keys = [var.instance_root_ssh_key]

    group = var.instance_group
    tags = [ var.instance_group ]
    private_ip = true
}