output "k8s_master_public_ip" {
  value = "${scaleway_ip.master.ip}"
}

output "k8s_master_private_ip" {
  value = "${scaleway_server.kube-master.private_ip}"
}

output "k8s_worker_public_ip" {
  value = "${scaleway_ip.worker.ip}"
}

output "k8s_worker_private_ip" {
  value = "${scaleway_server.kube-worker.private_ip}"
}
