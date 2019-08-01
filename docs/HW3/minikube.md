## Ход выполнения ДЗ 
 
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

  - установлен MetalLB. Проверка объектов командой:
    ~~~~
    kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.0/manifests/metallb.yaml
    kubectl --namespace metallb-system get all
    kubectl apply -f metallb-config.yaml
    ~~~~

  - проверка работы балансировщика (убеждаемся, что ответы приходят от разных pod-ов, а если присмотреться, то можно увидеть, что pod-ы выбираются по алгоритму Round-Robin):
  ~~~~
  $ while true; do curl --silent http://172.17.255.1 | grep HOSTNAME; sleep 2; done
  ~~~~

  - вместо колдовства с маршрутизацией извне в кластер (миникуба), можно использовать kube-forward на pod ingress-nginx-а. Результат аналогичен:
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

Альтернативный старт миникуба (proxy.Mode не работает)
minikube start --vm-driver hyperkit --memory=4096 --service-cluster-ip-range=10.96.0.0/16 --extra-config=proxy.Mode=ipvs


Прокидывание ClusterIP
minikube tunnel

Добавляем одиночный IP
sudo route add 172.17.255.1 192.168.64.7

Добавляем подсеть
sudo route add 172.17.255.0/24 $(minikube ip)

Проверка роутинга
netstat -nr | grep 192.168.64.7

kubectl cluster-info dump --all-namespaces=true --output-directory="."
