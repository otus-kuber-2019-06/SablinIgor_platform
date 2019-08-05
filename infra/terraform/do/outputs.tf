output "k8s_master_ip" {
  value = "${digitalocean_droplet.master-node.ipv4_address}"
}

output "k8s_worker_ip" {
  value = "${digitalocean_droplet.worker-node.ipv4_address}"
}
