
- установили докер

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

- установили репу кубера
- отключили SeLinux
- установили kubelet kubeadm kubectl
- и т.д. по документу

https://blog.espe.tech/2018-05-11/kubernetes-baremetal
https://github.com/kubernetes/kubeadm/issues/1390
- запустили kubeadm init

sudo kubeadm init \
    --pod-network-cidr=10.244.0.0/16 \
    --apiserver-advertise-address=0.0.0.0 \
    --apiserver-cert-extra-sans=10.18.108.11,51.158.178.153
   

kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=0.0.0.0 --apiserver-cert-extra-sans=<PRIVATE_IP>[,<PUBLIC_IP>,...]

https://www.linode.com/docs/applications/containers/getting-started-with-kubernetes/
- установили калико

- настроили контекст/конфиг

- перенести конфиг на рабочую станцию

https://github.com/kubernetes/dashboard
- установка дашборда


- скисок имаджей 
https://api-marketplace.scaleway.com/images




# поднимаем мастер ноду (infra/scaleway/sl.tf)
terraform apply --auto-approve

# install Docker
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker-ce-18.06.1.ce-3.el7

sudo systemctl enable docker.service

# install kubeadm
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

setenforce 0  (проверка /usr/sbin/getenforce)

sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

modprobe br_netfilter

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

# Creating a single control-plane cluster with kubeadm

ip -c a  //  IPADDR=$(hostname -I|awk '{print $1}')

sudo kubeadm init \
    --pod-network-cidr=10.244.0.0/16 \
    --apiserver-advertise-address=0.0.0.0 \
    --apiserver-cert-extra-sans=10.18.108.11,51.158.178.153

# config
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# ставим сетевой плагин (калико)
kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml

# смотрим как ставится
watch kubectl get pods --all-namespaces

# переносим ~/.kube/config на рабочую станцию

# устанавливаем переменную окружения
KUBECONFIG=~/.kube/config

# проверяем работу с локальной станции
kubectl config view
kubectl config get-contexts 
kubectl get nodes
