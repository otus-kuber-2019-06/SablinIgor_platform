provider "scaleway" {
  organization = "${var.organization_id}"
  token        = "${var.token}"
  region       = "ams1"
}

resource "scaleway_ip" "master" {
  count = 1
}

resource "scaleway_ip" "worker" {
  count = 1
}

resource "scaleway_server" "kube-master" {
  name  = "k8s-master"
  image = "05794ee5-c6d2-4d69-86dd-f1fc9032921d"
  type  = "DEV1-S"

  public_ip     = "${scaleway_ip.master.ip}"

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file("/Users/admin/.ssh/id_rsa")}"
  }

  provisioner "remote-exec" {
    inline = [
      "setenforce 0",
      "sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config",
      "yum install -y libselinux-python"
    ]
  }
}

resource "scaleway_server" "kube-worker" {
  name  = "k8s-worker"
  image = "05794ee5-c6d2-4d69-86dd-f1fc9032921d"
  type  = "DEV1-M"

  public_ip     = "${scaleway_ip.worker.ip}"

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file("/Users/admin/.ssh/id_rsa")}"
  }
  provisioner "remote-exec" {
    inline = [
      "setenforce 0",
      "sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config",
      "yum install -y libselinux-python"
    ]
  }
}

resource "scaleway_security_group" "http" {
  name        = "http"
  description = "allow HTTP and HTTPS traffic"
}

resource "scaleway_security_group" "k8s_api" {
  name        = "k8s_api"
  description = "allow k8s api traffic"
}

resource "scaleway_security_group_rule" "http_accept" {
  security_group = "${scaleway_security_group.http.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port      = 80
}

resource "scaleway_security_group_rule" "https_accept" {
  security_group = "${scaleway_security_group.http.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port      = 443
}

resource "scaleway_security_group_rule" "k8s_api_accept" {
  security_group = "${scaleway_security_group.k8s_api.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port      = 6443
}

/*
curl -v \
    -H "X-Auth-Token: be3b0280-cf1a-4f76-9027-8c7b7f9570ff" \
    -H 'Content-Type: application/json' \
    "https://cp-ams1.scaleway.com/images"
*/
