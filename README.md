# SablinIgor_platform
SablinIgor Platform repository

# Выполнено ДЗ №1

 - [x] Основное ДЗ

## В процессе сделано:
 - Установлена консольная утилита k9s
 - Установлен плагин в оболочке zsh - kube-ps1
 - Работает кластер под управлением minikube
 - Проверка подключения к кластеру
   ~~~~
   kubectl cluster-info
   ~~~~
 - Запуск дашборда миникуба
   ~~~~
   minikube dashboard
   ~~~~
 - Проверена живучесть кластера путем принудительного убиения контейнеров. Поды, управляемые через ReplicaSet восстанавливаются автоматически. kube-apiserver управляется через сервисы ОС.
 - Создан Dockerfile для образа веб-сервера (используется модуль Python http.server)
 - Создан манифест для пода, содержащего контейнер с веб-сервером
 - В поде используется инит-контейнер для создания веб-страницы
 - Веб-страница сохраняется в volume типа emptyDir
 - Для доступа к поду используется kubectl port-forward (или kube-forwarder - тоже самое, только в профиль)

## Полезные команды
 - minikube ssh - зайти на воркер
 - docker rm -f $(docker ps -a -q) - удаление всех контейнеров
 - kubectl get pods -n kube-system - смотрим под-ы в заданном namespace-е
 - kubectl delete pod --all -n kube-system - удаляем все под-ы в заданном namespace-е
 - kubectl get cs - состояние controle plane
 - kubectl apply -f web-pod.yaml - запуск манифеста
 - kubectl get pod web -o yaml - смотрим манифест
 - kubectl describe pod web - описание и состояние объекта, включая события
 - kubectl get pods -w - отслеживаем состояние под-ов в онлайне
 - kubectl port-forward --address 0.0.0.0 pod/web 8000:8000 - прокидываем порты 

## Использованные источники
 - https://k9ss.io/
 - https://github.com/jonmosco/kube-ps1
 - https://appdividend.com/2019/02/06/python-simplehttpserver-tutorial-with-example-http-request-handler/
 - https://docs.python.org/2/library/simplehttpserver.html
 - https://stackoverflow.com/questions/51016945/create-a-dockerfile-that-runs-a-python-http-server-to-display-an-html-file
 - https://runnable.com/docker/python/dockerize-your-python-application
 - https://blog.realkinetic.com/building-minimal-docker-containers-for-python-applications-37d0272c52f3
 - https://stackoverflow.com/questions/9224298/how-do-i-fix-certificate-errors-when-running-wget-on-an-https-url-in-cygwin
 - https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
 - https://kube-forwarder.pixelpoint.io/

# Выполнено ДЗ №2

 - [x] Основное ДЗ

## В процессе сделано:
 - Задания выполнены в каталоге kubernetes-security
 - Выполнено задание 1
   - создана сервисная учетная запись bob с ролью админ в рамках кластера
     ~~~~
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        name: bob
      ---
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRoleBinding
      metadata:
        name: admin-test
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: admin
      subjects:
      - kind: ServiceAccount
        name: bob
        namespace: default
     ~~~~
   - создана сервисная учетная запись dave без доступа к кластеру (т.е. без прикрепления ролей)
     ~~~~
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        name: dave
     ~~~~
 - Выполнено задание 2
   - создано пространство имен prometheus
     ~~~~
      apiVersion: v1
      kind: Namespace
      metadata:
        name: prometheus
     ~~~~
   - создана сервисная учетная запись carol в пространстве prometheus
     ~~~~
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        name: carol
        namespace: prometheus
     ~~~~
   - всем сервисным учетным записям пространства prometheus прикреплена роль просмотра pod-ов всего кластера
     ~~~~
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRole
      metadata:
        name: prometheus-cr
      rules:
      - apiGroups:
        - ""
        resources:
        - pods
        verbs:
        - get
        - list
        - watch
      ---
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRoleBinding
      metadata:
        name: prometheus-crb
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: prometheus-cr
      subjects:
      - kind: Group
        name: system:serviceaccounts:prometheus
        apiGroup: rbac.authorization.k8s.io
     ~~~~
 - Выполнено задание 3
   - создано пространство имен dev
     ~~~~
      apiVersion: v1
      kind: Namespace
      metadata:
        name: dev
     ~~~~
   - создана сервисная учетная запись jane в пространстве dev
     ~~~~
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        name: jane
        namespace: dev
     ~~~~
   - к учетной сервисной записи jane прикреплена роль admin в рамках пространства dev
     ~~~~
      apiVersion: rbac.authorization.k8s.io/v1
      kind: RoleBinding
      metadata:
        name: admin-jane
        namespace: dev
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: admin
      subjects:
      - kind: ServiceAccount
        name: jane
        namespace: dev
     ~~~~
   - создана сервисная учетная запись ken в пространстве dev
     ~~~~
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        name: ken
        namespace: dev
     ~~~~
   - к учетной сервисной записи ken прикреплена роль view в рамках пространства dev
     ~~~~
      apiVersion: rbac.authorization.k8s.io/v1
      kind: RoleBinding
      metadata:
        name: view-ken
        namespace: dev
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: view
      subjects:
      - kind: ServiceAccount
        name: ken
        namespace: dev
     ~~~~

## Использованные источники
  - https://kubernetes.io/docs/reference/access-authn-authz/rbac/
  - https://2rwky424s9rd179jmbzqsca1-wpengine.netdna-ssl.com/wp-content/uploads/2019/04/Kubernetes-Cheat-Sheet_07182019.pdf
  - https://github.com/FairwindsOps/rbac-lookup


# Выполнено ДЗ №4

 - [x] Основное ДЗ
 - [x] Задание со *

## В процессе сделано:
 - для работы используется Amazon S3 Compatible Object Storage - Minio (https://min.io/)
 - так же используется дефолтный StarageClass
  ~~~~
    $ kubectl get storageclass
    NAME                 PROVISIONER               AGE
    standard (default)   kubernetes.io/host-path   90m
  ~~~~
 - для подключения к под-у хранилища используется конструкция, характерная для объектов вида StatefulSet
  ~~~~
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 10Gi
  ~~~~ 
 - для обеспечения доступности Minio внутри кластера используется Headless Service
 - настроены секреты с логином/паролем (kubernetes-volumes/01-credentials.yaml)
 - в манифесте под-а используются ссылки на секреты для переменных окружения
  ~~~~
    env:
    - name: MINIO_ACCESS_KEY
      valueFrom: 
        secretKeyRef:
          name: minio-secret
          key: MINIO_ACCESS_KEY
  ~~~~

## Использованные источники
 - https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets
 - https://ealebed.github.io/posts/2018/%D0%B7%D0%BD%D0%B0%D0%BA%D0%BE%D0%BC%D1%81%D1%82%D0%B2%D0%BE-%D1%81-kubernetes-%D1%87%D0%B0%D1%81%D1%82%D1%8C-14-%D1%81%D0%B5%D0%BA%D1%80%D0%B5%D1%82%D1%8B-secrets/

## Полезные команды
 - kubectl get statefulsets
 - kubectl get pods
 - kubectl get pvc
 - kubectl get pv
 - kubectl describe [resource] [resource_name]

# Выполнено ДЗ №3

 - [x] Основное ДЗ
 - [x] Задание со *

## В процессе сделано:
 - используется minikube c драйвером VM HyperKit
  ~~~~
  minikube start --vm-driver hyperkit
  ~~~~
 - переключение контекста на миникуб
  ~~~~
  kubectl config use-context minikube  
  ~~~~
 - установлен kubespy
  ~~~~
  brew install kubespy
  ~~~~
  - в манифесты добавлены readinessProbe и livenessProbe для проверки готовности и жизни контейнера
  ~~~~
    readinessProbe:
      httpGet:
        path: /index.html
        port: 80
    livenessProbe:
      tcpSocket: { port: 8000 }
  ~~~~
  - использовать 'ps aux' для проверки жизни контейнера допускается, но я смысла в этом не вижу, так как наличие запущенного процесса еще не гарантирует, что он выполняет свою работу.
  - --force полезный ключ для принудительного применения манифеста
  - Состояние запуска deployment можно отследить в блоке Conditions
  ~~~~
    Conditions:
    Type        Status  Reason
    ----        ------  ------
    Available   False   MinimumReplicasUnavailable
    Progressing True    ReplicaSetUpdated
  ~~~~
  - проведены эксперименты со значениями maxUnavailable и maxSurge
    ~~~~
    rollingUpdate:
    maxUnavailable: 100%
    maxSurge: 0
    ~~~~
    - задавать одновременно нули не имеет смысла, так как если нельзя выйти за пределы кол-ва реплик с новой версией приложения
    - maxUnavailable: 100% и maxSurge: 0 - отказ в обслуживании на время обновления.
      ~~~~
      $ kubectl rollout status deployment web                              
      Waiting for deployment "web" rollout to finish: 0 of 3 updated replicas are available...
      Waiting for deployment "web" rollout to finish: 2 of 3 updated replicas are available...
      deployment "web" successfully rolled out
      ~~~~
    - maxUnavailable: 0 и maxSurge: 100% - к имеющимся репликам добавляется такое же кол-во новых и "устаревшие" уничтожаются
    $ kubectl rollout status deployment web
      ~~~~
      Waiting for deployment "web" rollout to finish: 3 old replicas are pending termination...
      Waiting for deployment "web" rollout to finish: 2 old replicas are pending termination...
      Waiting for deployment "web" rollout to finish: 2 old replicas are pending termination...
      deployment "web" successfully rolled out
      ~~~~

  - для маршрутизации и балансировки трафика включен IPSV
     - открывается файл конфигурации
     ~~~~
     kubectl --namespace kube-system edit configmap/kube-proxy
     ~~~~
     - значение параметра mode меняется на ipvs

  - до включения ipsv правила маршрутизации выглядят так: https://pastebin.com/X9KeP528
  - сразу после так: https://pastebin.com/82xTiKJd
  - после очистки от устаревших правил: https://pastebin.com/CdbzVNU3
  - через некоторое вермя (пока kube-proxy добавляет нужные маршруты): https://pastebin.com/JNpp4tsZ

  - маршрутизацию сервисов можно смотреть при помощи команды:
    ~~~~
    $ ipvsadm --list -n
    IP Virtual Server version 1.2.1 (size=4096)
    Prot LocalAddress:Port Scheduler Flags
      -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
    TCP  10.110.197.49:80 rr
      -> 172.17.0.5:8000              Masq    1      0          0         
      -> 172.17.0.6:8000              Masq    1      0          0         
      -> 172.17.0.7:8000              Masq    1      0          0 
    ~~~~
    
  - появляется возможность сделать ping (если вдруг захочется)
    ~~~~
    $ ping -c1 10.110.197.49
    PING 10.110.197.49 (10.110.197.49): 56 data bytes
    64 bytes from 10.110.197.49: seq=0 ttl=64 time=0.106 ms

    --- 10.110.197.49 ping statistics ---
    1 packets transmitted, 1 packets received, 0% packet loss
    ~~~~
    
  - причина - появление ip пода среди сетевых интерфейсов
    ~~~~
    $ ip addr show kube-ipvs0
    65: kube-ipvs0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default 
        link/ether f2:76:4a:27:a0:88 brd ff:ff:ff:ff:ff:ff
        inet 10.110.197.49/32 brd 10.110.197.49 scope global kube-ipvs0
    ~~~~

  - при необходимости посмотреть хэш-таблицу, заменяющую цепочку правил iptables, можно воспользоваться командой:
    ~~~~
    $ ipset -L KUBE-CLUSTER-IP
    Name: KUBE-CLUSTER-IP
    Type: hash:ip,port
    Revision: 5
    Header: family inet hashsize 1024 maxelem 65536
    Size in memory: 408
    References: 2
    Number of entries: 6
    Members:
    10.102.96.20,tcp:80
    10.110.197.49,tcp:80
    10.96.0.10,udp:53
    10.96.0.10,tcp:53
    10.96.0.10,tcp:9153
    10.96.0.1,tcp:443
    ~~~~

  - установлен MetalLB. Проверка объектов командой:
    ~~~~
    kubectl --namespace metallb-system get all
    ~~~~

  - проверка работы балансировщика (убеждаемся, что ответы приходят от разных под-ов, а если присмотреться, то можно увидеть, что под-ы выбираются по алгоритму Round-Robin):
  ~~~~
  $ while true; do curl --silent http://172.17.255.1 | grep HOSTNAME; sleep 2; done
  ~~~~

  - вместо колдовства с маршрутизацией извне в кластер (миникуба), можно использовать kube-forward на под ingress-nginx-а. Результат аналогичен:
  ~~~~
  curl http://localhost:4444/ 
  <html>
  <head><title>404 Not Found</title></head>
  <body>
  <center><h1>404 Not Found</h1></center>
  <hr><center>openresty/1.15.8.1</center>
  </body>
  </html> 
  ~~~~

  - с небольшой доработкой прошло и внешнее подключение к ингрессу (при условии форварда из предыдущего пункта):
    - https://pasteboard.co/IpnhOxX.png
  ~~~~
  spec:
    rules:
    - host: localhost
  ~~~~

  - может когда-нибудь пригодится: /usr/share/logstash/bin/logstash -t -f /etc/logstash/conf.d/ - проверка кофигурации

## Использованные источники
 - https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#hyperkit-driver
 - https://github.com/pulumi/kubespy
 - https://ixnfo.com/ustanovka-i-ispolzovanie-ipset.html
 - https://kubernetes.io/blog/2018/07/09/ipvs-based-in-cluster-load-balancing-deep-dive/
 - https://banzaicloud.com/blog/kind-ingress/
