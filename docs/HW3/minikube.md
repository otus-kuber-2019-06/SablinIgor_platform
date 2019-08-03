## Ход выполнения ДЗ 
 
 - используется minikube c драйвером VM HyperKit (для звездочек и для заданий, подразумевающих обращение "снаружи" миникуба - на virtualbox, так как использовался ubuntu-виртуалка на bare-metal)
  ~~~~
  minikube start --vm-driver hyperkit
  ~~~~
 - переключение контекста на миникуб
  ~~~~
  kubectl config use-context minikube  
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

     kubectl --namespace kube-system delete pod --selector='k8s-app=kube-proxy'

     /tmp/iptables.cleanup

      *nat
      -A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
      COMMIT
      *filter
      COMMIT
      *mangle
      COMMIT

      sudo iptables-restore /tmp/iptables.cleanup

      sudo iptables --list -nv -t nat

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

  - установлен MetalLB
    ~~~~
    kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.0/manifests/metallb.yaml
    kubectl --namespace metallb-system get all
    kubectl apply -f metallb-config.yaml
    ~~~~

  - проверка работы балансировщика (убеждаемся, что ответы приходят от разных pod-ов, а если присмотреться, то можно увидеть, что pod-ы выбираются по алгоритму Round-Robin):
    ~~~~
    $ while true; do curl --silent http://172.17.255.1 | grep HOSTNAME; sleep 2; done
    ~~~~

  - для обращения к балансировщику "снаружи" от миникуба необходимо пробросить маршрут для нужной подсети через IP миникуба
    - узнаем IP
    ~~~~
    $ minikube ip
    ~~~~
    - прописываем маршрут
    ~~~~
    ip route add 172.17.255.0/24 via 192.168.99.100
    ~~~~

  - ЗАДАНИЕ СО ЗВЕЗДОЧОЙ

    - для обращения к coredns создаем два сервиса типа Load Balancer (так как мультипорт в LB не подерживается)
    - чтобы оба сервиса имели один IP используем аннотацию metallb.universe.tf/allow-shared-ip и spec.loadBalancerIP c желаемым адресом (для гарании)
    - реализация в файле kubernetes-networks/dns-svc-lb.yaml
    - для обращения к сервису nslookup необходимо использовать ПОЛНОЕ имя сервиса!
    ~~~~
    [admin@sandbox ~]$ nslookup kubernetes.default.svc.cluster.local 172.17.255.2
    Server:        172.17.255.2
    Address:    172.17.255.2#53
    Name:    kubernetes.default.svc.cluster.local
    Address: 10.96.0.1
    ~~~~

  - Подключение Ingress

    - Основной манифест: kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

    - Конфигурация ingress определяется в манифесте kubernetes-networks/nginx-lb.yaml

    - Проверить корректность начальной установки можно обратившись по адресу ingress-контроллера. Мы должны получить 404-ый ответ:
      ~~~~
      [admin@sandbox ~]$ curl -kL http://ingress.example.com
      <html>
      <head><title>404 Not Found</title></head>
      <body>
      <center><h1>404 Not Found</h1></center>
      <hr><center>openresty/1.15.8.1</center>
      </body>
      </html>
      ~~~~

- ЗАДАНИЕ СО ЗВЕЗДОЧОЙ
  - Canary deploy

  - Для демонстрации возможностей Canary-деплоя приложения были созданы:
    - два докер-образа сервиса, возвращающие номер версии (0.1 и 0.2) - soaron/test-rest:0.1 и soaron/test-rest:0.2. Исходный код сервиса: /kubernetes-networks/canary
    - манифесты для кубернетеса находятся в каталоге kubernetes-networks/canary/manifest
    - манифест деплоя приложения и создания сервиса: test-rest-stable.yaml и test-rest-ingress.yaml
    - манифест деплоя новой приложения и создания сервиса (предполагается деплой в отдельном namespace test-canary): test-rest-canary.yaml и test-rest-ingress-canary.yaml
  - процесс деплоя выглядит следующим образом
    ~~~~
    $ kubectl apply -f test-rest-stable.yaml
    $ kubectl apply -f test-rest-svc.yaml
    $ kubectl create ns test-canary
    $ kubectl apply -f test-rest-canary.yaml -n test-canary
    $ kubectl apply -f test-rest-ingress-canary.yaml
    ~~~~
  - демонстрация того, что на canary-приложение уходит 30% трафика (соответственно настройкам в ingress)
    ~~~~
    [admin@sandbox manifest]$ while true; do curl --silent http://ingress.example.com/test; printf "\n"; sleep 2; done
    Version: 0.1
    Version: 0.1
    Version: 0.2
    Version: 0.1
    Version: 0.1
    Version: 0.1
    Version: 0.2
    Version: 0.1
    Version: 0.1
    Version: 0.2
    ~~~~
