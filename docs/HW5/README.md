# Выполнено ДЗ №5

 - [x] Основное ДЗ
 - [x] Задание со *

## В процессе сделано:

### Настройка инфраструктуры

Для установки кубернетес-кластера используются виртуальные машины поднятые на Proxmox-сервере.
Для этого используется плейбук ансибла - kubernetes-upgrade/ansible/playbooks/create_vm.yml: создается один мастер-узел и три рабочих узла.

~~~~
ansible-playbook playbooks/create_vm.yml --extra-vars="api_password=XXXXXXXX"
~~~~

### Предварительные настройки узлов

При помощи playbook-а kubernetes-upgrade/ansible/playbooks/setup_vm.yml:
  - установлен docker версии 18.06
  - отключен swap
  - включена маршрутизация (net.ipv4.ip_forward = 1 >> /etc/sysctl.conf)
  - отключен firewall
~~~~
ansible-playbook playbooks/setup_vm.yml
~~~~

### Установка утилит

Для инициализации и последующей работы с кластером установлены утилиты
  - kubelet
  - kubeadm
  - kubectl

Пример установки для Ubuntu
~~~~
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet=1.14.5-00 kubeadm=1.14.5-00 kubectl=1.14.5-00
~~~~

### Создание кластера

Используем утилиту kubeadm

~~~~
kubeadm init --pod-network-cidr=192.168.0.0/24
~~~~

Из лога выполнения получаем путь к конфиг-файлу kubectl, команду для подключения рабочего узла

Пока мы не установим сетевой плагин, узел будет в нерабочем состоянии

~~~~
NAME             STATUS   ROLES    AGE   VERSION
master.otus.ru   NotReady    master   25m   v1.14.5

[sablin@master ~]$ kubectl describe node master.otus.ru
Name:               master.otus.ru
Roles:              master

...

Unschedulable:      false
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------

...

  Ready            False   Sat, 17 Aug 2019 15:23:30 +0200   Sat, 17 Aug 2019 15:03:24 +0200   KubeletNotReady              runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
~~~~

### Установка сетевого плагина

Используем Calico

~~~~
kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml
~~~~

### Подлючаем рабочие узлы

Используем команду, полученную из лога выполнения kubeadm

Пример команды:

~~~~
kubeadm join 10.21.21.51:6443 --token 7p1bp3.j2xaljvc68t7xa7j \
    --discovery-token-ca-cert-hash sha256:10e1d8604317da422f2faabc7c27fe4bb630ace04be583efd14605b793ee73df
~~~~

### Установка Load Balancer

Используется MetalLB

~~~~
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.0/manifests/metallb.yaml
kubectl apply -f kubernetes-upgrade/manifests/metallb-config.yaml
~~~~

### Установка приложения

В качестве демонстрационного приложения будет использован nginx.
Доступ предоставляется через Load Balancer.
Указано установить три реплики приложения (по кол-ву узлов!!!)

~~~~
kubectl apply -f kubernetes-upgrade/manifests/deployment.yaml
~~~~

### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
### Самозадание со звездочкой *
### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

### Мониторинг работы приложения под максимальной нагрузкой при обновлении кластера.

Для демонстрации возможного влияния обновления кластера на произовдительность приложения будет использоваться:
  - стек мониторинга на основе ELK
  - генератор нагрузки Яндекс.Танк 

Инфраструктура:
  - сервер Elasticsearch
  - сервер Kibana
  - докер-образ Яндекс.Танка на мастер-узле кластера

### Установка Elasticsearch

Устанавливаем java

~~~~
sudo apt install openjdk-11-jre-headless
~~~~

Смотрим куда установилась

~~~~
update-alternatives --config java
~~~~

Указываем в переменную JAVA_HOME путь к каталогу (без /bin/java). Переменную определяем в файле /etc/environment.

~~~~
sablin@elasticsearch:~$ cat /etc/environment
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
~~~~

Отключаем firewall

~~~~
sudo ufw disable
~~~~

Ставим Elasticsearch

~~~~
sudo apt-get install apt-transport-https
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo add-apt-repository "deb https://artifacts.elastic.co/packages/7.x/apt stable main"
sudo apt-get update
sudo apt-get install elasticsearch
~~~~

Правим файл с конфигурацией (/etc/elasticsearch/elasticsearch.yml)

~~~~
network.host: 10.21.21.85
discovery.seed_hosts: ["127.0.0.1", "[::1]"]
cluster.initial_master_nodes: ["10.21.21.85"]
~~~~

Запускаем

~~~~
sudo /bin/systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
~~~~

Проверяем

~~~~
~ curl 10.21.21.85:9200
{
  "name" : "elasticsearch",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "_na_",
  "version" : {
    "number" : "7.3.0",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "de777fa",
    "build_date" : "2019-07-24T18:30:11.767338Z",
    "build_snapshot" : false,
    "lucene_version" : "8.1.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
~~~~

### Установка Kibana

Собственно установка

~~~~
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install kibana
~~~~

Правим конфигурацию: указываем с каких адресов принимать запросы и по какому url-у доступен Elasticsearch.
Файл конфигурации - /etc/kibana/kibana.yml

~~~~
server.host: 0.0.0.0
elasticsearch.hosts: ["http://10.21.21.85:9200"]
~~~~

Запускаем

~~~~
sudo /bin/systemctl enable kibana.service
sudo systemctl start kibana.service
~~~~

Проверяем

~~~~
$ curl localhost:5601
~~~~

Ничего не вернуло - это хорошо. Если что-то пойдет не так, вернется сообщение, что сервер не доступен.

### Установка fluentd

Устанавливается как DaemonSet на все узлы

~~~~
kubectl apply -f kubernetes-upgrade/manifests/fluentd.yaml
~~~~

### Настройка index-а в Kibana

Заходим в Management - Kibana - Index Patterns.
К этому моменту у нас уже должны были накопиться логи, поэтому в поле Index pattern указываем "logstash-*" 

![First step](https://logz.io/wp-content/uploads/2019/05/step-1-min.png)

Далее выбираем поле, по которому будет определяться дата и время - @timestamp

![Second step](https://logz.io/wp-content/uploads/2019/05/step-2-min.png)

И создаем индекс, кликая на кнопку "Create index pattern"


### Подготовка конфигурации нагрузки

В файле load.yaml указываем порядок тестирования:
  - подаем постоянную нагрузку в течении 40 минут (пока обновляем кластер) 15000 запросов в секунду (rps)

### Запускаем нагрузку

Для запуска нагрузки используем официальный docker-образ танка:

~~~~
$ docker run -v $(pwd):/var/loadtest -v $SSH_AUTH_SOCK:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent --net host -it direvius/yandex-tank
~~~~

![Maximum](https://i.snipboard.io/RZu8JM.jpg)

### Обновляем мастер

Скачиваем желаемую версию kubeadm

~~~~
sudo yum install -y kubeadm-1.15.0-0 --disableexcludes=kubernetes
~~~~

Смотрим что будет обновляться

~~~~
sudo kubeadm upgrade plan
~~~~

Обновляем

~~~~
sudo kubeadm upgrade apply v1.15.0
~~~~

Скачиваем новые версии kubelet и kubectl

~~~~
yum install -y kubelet-1.15.0-0 kubectl-1.15.0-0 --disableexcludes=kubernetes
~~~~

Перезапускаем kubelet

~~~~
sudo systemctl restart kubelet
~~~~

Влияния на производительность не замечено.

Приложения остаются распределенными по трем нодам

~~~~
[sablin@master ~]$ kubectl get po -o wide
NAME                               READY   STATUS    RESTARTS   AGE    IP                NODE              NOMINATED NODE   READINESS GATES
nginx-deployment-ffcdc8c44-5lkj8   1/1     Running   0          3h2m   192.168.96.201    worker1.otus.ru   <none>           <none>
nginx-deployment-ffcdc8c44-s5dpc   1/1     Running   0          3h2m   192.168.28.9      worker3.otus.ru   <none>           <none>
nginx-deployment-ffcdc8c44-xklnm   1/1     Running   0          3h2m   192.168.101.202   worker2.otus.ru   <none>           <none>
~~~~

### Обновляем первый рабочий узел

Скачиваем желаемую версию kubeadm

~~~~
sudo yum install -y kubeadm-1.15.0-0 --disableexcludes=kubernetes
~~~~

Выводим узел из эксплуатации

~~~~
kubectl drain $NODE --ignore-daemonsets
~~~~

Обновляем конфигурацию kubelet

~~~~
sudo kubeadm upgrade node
~~~~

Скачиваем новые версии kubelet и kubectl

~~~~
yum install -y kubelet-1.15.0-0 kubectl-1.15.0-0 --disableexcludes=kubernetes
~~~~

Перезапускаем kubelet

~~~~
sudo systemctl restart kubelet
~~~~

Возвращаем ноду в эксплуатацию

~~~~
kubectl uncordon $NODE
~~~~

После того как мы выводим узел из эксплуатации - дополнительная реплика приложения разворачивается на одном из оставшихся узлов.

~~~~
[sablin@master ~]$ kubectl get po -o wide
NAME                               READY   STATUS    RESTARTS   AGE    IP                NODE              NOMINATED NODE   READINESS GATES
nginx-deployment-ffcdc8c44-86txv   1/1     Running   0          57s    192.168.28.10     worker3.otus.ru   <none>           <none>
nginx-deployment-ffcdc8c44-s5dpc   1/1     Running   0          3h3m   192.168.28.9      worker3.otus.ru   <none>           <none>
nginx-deployment-ffcdc8c44-xklnm   1/1     Running   0          3h3m   192.168.101.202   worker2.otus.ru   <none>           <none>
~~~~

Обращаем внимание, что во время вывода узла из эксплуатации производительность приложения уменьшилась.

![Drain node](https://i.snipboard.io/2OyFib.jpg)

Более того, после того как мы возвращаем узел в эксплуатацию, увеличения производительности не происходит, так как реплики приложения остаются на тех же двух узлах, что и раньше.

### Обновляем остальные рабочие узлы

По такому же принципу обновляем остальные рабочие узлы.
Обращаем внимание, что призводительность остается на пониженном уровне, так как равномерного перераспределения приложения по трем узлам не происходит.

### Восстановление максимальной производительности

Чтобы вернуться к изначальному распределению приложений по узлам - удалим одно из двух, расположенных на одном узле, приложений. При этом, новый под будет запущен на "пустом" узле и максимальная нагрузка восстановится.

~~~~
[sablin@master ~]$ kubectl delete po nginx-deployment-ffcdc8c44-86txv
pod "nginx-deployment-ffcdc8c44-86txv" deleted
[sablin@master ~]$ kubectl get po -o wide
NAME                               READY   STATUS    RESTARTS   AGE    IP                NODE              NOMINATED NODE   READINESS GATES
nginx-deployment-ffcdc8c44-lsg8l   1/1     Running   0          9s     192.168.96.202    worker1.otus.ru   <none>           <none>
nginx-deployment-ffcdc8c44-s5dpc   1/1     Running   0          3h8m   192.168.28.9      worker3.otus.ru   <none>           <none>
nginx-deployment-ffcdc8c44-xklnm   1/1     Running   0          3h8m   192.168.101.202   worker2.otus.ru   <none>           <none>
~~~~

![Maximum again](https://i.snipboard.io/8Tm2Ye.jpg)
