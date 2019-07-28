resource "digitalocean_droplet" "worker-node" {
    image = "centos-7-x64"
    name = "master"
    region = "fra1"
    size = "s-2vcpu-2gb"
    private_networking = true
    ssh_keys = [
      "${var.ssh_fingerprint}"
    ]

  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "setenforce 0",
      "sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config",
      "yum install -y libselinux-python",
      "yum install -y vim"
    ]
  }
}

