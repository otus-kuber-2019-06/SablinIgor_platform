## Создание инфраструктуры
- перейти в каталог infra/scaleway
- запустить terraform apply --auto-approve

## Подготовка установки
- загрузить репозиторий kubespray: git clone https://github.com/kubernetes-sigs/kubespray.git
- перейти в каталог kubespray
- скачать зависимости: sudo pip install -r requirements.txt
- подготовить inventory: cp -rfp inventory/sample inventory/mycluster 
- в файле inventory.ini указать внешние и внутренние адреса для master и worker узлов
- в файле infra/kubespray/inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml для переменной supplementary_addresses_in_ssl_keys указать внешние IP узлов

## Запуск установки
ansible-playbook -i inventory/mycluster/inventory.ini --become -u root --private-key ~/.ssh/id_rsa --flush-cache cluster.yml

## Создание админского пользователя
~~~~
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
~~~~
~~~~
kubectl apply -f kubernetes-networks/admin-sa.yaml
~~~~

## Привязываем роль

~~~~
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
~~~~

~~~~
kubectl apply -f kubernetes-networks/admin-rb.yaml 
~~~~ 

## Получаем токен
~~~~
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
~~~~

## Проверяем доступность dashboard

Заходим на https://<master-ip>:<apiserver-port>/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/ с авторизацией по токену

## Установка Load balancer (предварительно указав IP в metallb-config.yaml)
~~~~
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.0/manifests/metallb.yaml
kubectl --namespace metallb-system get all
kubectl apply -f kubernetes-networks/metallb-config.yaml
~~~~

## Enable SSL passthrough option on Nginx Ingress Controller
~~~~
kubectl get daemonset ingress-nginx-controller -n ingress-nginx
~~~~
В секцию containers добавляем аргумент --enable-ssl-passthrough=true

Проверяем 
~~~~
$ kubectl get ds ingress-nginx-controller -n ingress-nginx -oyaml | grep ssl -B 4
        - --configmap=$(POD_NAMESPACE)/ingress-nginx
        - --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services
        - --udp-services-configmap=$(POD_NAMESPACE)/udp-services
        - --annotations-prefix=nginx.ingress.kubernetes.io
        - --enable-ssl-passthrough=true
~~~~

## Удаление кластер
-  в каталоге infra/scaleway запусить: terraform destroy --auto-approve
