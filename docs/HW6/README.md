# Выполнено ДЗ №6

 - [x] Основное ДЗ
 - [x] Задание со *

## В процессе сделано:

### Задание обычное

1. При создании кластера используется конфиг с указанием включить флаг VolumeSnapshotDataSource.
   Без него CSI не сможет восстановить данные из snapshot-а.
   При создании кластера используем одноузловую схему. Для кластера с несколькими узлами понадобятся дополнительные пляски с бубном.

~~~~bash
kind create cluster --config ~/kind/config/cluster.yaml --wait 300s
~~~~

2. Скачиваем и устанавливаем CSI-драйвер

~~~~bash
git clone https://github.com/kubernetes-csi/csi-driver-host-path.git

./csi-driver-host-path/deploy/kubernetes-1.15/deploy-hostpath.sh
~~~~

3. Последовательно устанавливаем манифесты с:

   - Storage Class-ом: kubernetes-storage/hw/01-storage-class.yaml

   - Persistent Volume Claim: kubernetes-storage/hw/02-pvc.yaml

   - Собственно pod: kubernetes-storage/hw/03-pod-pvc.yaml

4. Смотрим на результат

~~~~
[admin@sandbox manifests]$ kubectl describe pod storage-pod
Name:         storage-pod
Namespace:    default
Priority:     0
Node:         kind-control-plane/192.168.254.2
Start Time:   Tue, 03 Sep 2019 11:00:39 -0400
Labels:       name=storage-pod
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"name":"storage-pod"},"name":"storage-pod","namespace":"default"},"...
Status:       Pending
IP:
Containers:
  busybox:
    Container ID:
    Image:         ubuntu
    Image ID:
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
    Args:
      tail -f /dev/null
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /data from vol (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-x77k8 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  vol:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  storage-pvc
    ReadOnly:   false
  default-token-x77k8:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-x77k8
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason                  Age   From                     Message
  ----    ------                  ----  ----                     -------
  Normal  Scheduled               5s    default-scheduler        Successfully assigned default/storage-pod to kind-control-plane
  Normal  SuccessfulAttachVolume  5s    attachdetach-controller  AttachVolume.Attach succeeded for volume "pvc-d4859557-0bb0-4c8c-84d2-6566e1164f96"
[admin@sandbox manifests]$ kubectl describe pod storage-pod
Name:         storage-pod
Namespace:    default
Priority:     0
Node:         kind-control-plane/192.168.254.2
Start Time:   Tue, 03 Sep 2019 11:00:39 -0400
Labels:       name=storage-pod
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"name":"storage-pod"},"name":"storage-pod","namespace":"default"},"...
Status:       Pending
IP:
Containers:
  busybox:
    Container ID:
    Image:         ubuntu
    Image ID:
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
    Args:
      tail -f /dev/null
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /data from vol (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-x77k8 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  vol:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  storage-pvc
    ReadOnly:   false
  default-token-x77k8:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-x77k8
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason                  Age   From                         Message
  ----    ------                  ----  ----                         -------
  Normal  Scheduled               7s    default-scheduler            Successfully assigned default/storage-pod to kind-control-plane
  Normal  SuccessfulAttachVolume  7s    attachdetach-controller      AttachVolume.Attach succeeded for volume "pvc-d4859557-0bb0-4c8c-84d2-6566e1164f96"
  Normal  Pulling                 2s    kubelet, kind-control-plane  Pulling image "ubuntu"
[admin@sandbox manifests]$ kubectl describe pod storage-pod
Name:         storage-pod
Namespace:    default
Priority:     0
Node:         kind-control-plane/192.168.254.2
Start Time:   Tue, 03 Sep 2019 11:00:39 -0400
Labels:       name=storage-pod
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"name":"storage-pod"},"name":"storage-pod","namespace":"default"},"...
Status:       Pending
IP:
Containers:
  busybox:
    Container ID:
    Image:         ubuntu
    Image ID:
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
    Args:
      tail -f /dev/null
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /data from vol (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-x77k8 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  vol:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  storage-pvc
    ReadOnly:   false
  default-token-x77k8:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-x77k8
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason                  Age   From                         Message
  ----    ------                  ----  ----                         -------
  Normal  Scheduled               9s    default-scheduler            Successfully assigned default/storage-pod to kind-control-plane
  Normal  SuccessfulAttachVolume  9s    attachdetach-controller      AttachVolume.Attach succeeded for volume "pvc-d4859557-0bb0-4c8c-84d2-6566e1164f96"
  Normal  Pulling                 4s    kubelet, kind-control-plane  Pulling image "ubuntu"
[admin@sandbox manifests]$ kubectl describe pod storage-pod
Name:         storage-pod
Namespace:    default
Priority:     0
Node:         kind-control-plane/192.168.254.2
Start Time:   Tue, 03 Sep 2019 11:00:39 -0400
Labels:       name=storage-pod
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"name":"storage-pod"},"name":"storage-pod","namespace":"default"},"...
Status:       Running
IP:           10.244.0.9
Containers:
  busybox:
    Container ID:  containerd://046d6c533fc73fd5677478d042699c97197ef30dc36acf949445697f5640053f
    Image:         ubuntu
    Image ID:      docker.io/library/ubuntu@sha256:d1d454df0f579c6be4d8161d227462d69e163a8ff9d20a847533989cf0c94d90
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
    Args:
      tail -f /dev/null
    State:          Running
      Started:      Tue, 03 Sep 2019 11:00:51 -0400
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /data from vol (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-x77k8 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  vol:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  storage-pvc
    ReadOnly:   false
  default-token-x77k8:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-x77k8
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason                  Age    From                         Message
  ----    ------                  ----   ----                         -------
  Normal  Scheduled               5m59s  default-scheduler            Successfully assigned default/storage-pod to kind-control-plane
  Normal  SuccessfulAttachVolume  5m59s  attachdetach-controller      AttachVolume.Attach succeeded for volume "pvc-d4859557-0bb0-4c8c-84d2-6566e1164f96"
  Normal  Pulling                 5m54s  kubelet, kind-control-plane  Pulling image "ubuntu"
  Normal  Pulled                  5m48s  kubelet, kind-control-plane  Successfully pulled image "ubuntu"
  Normal  Created                 5m48s  kubelet, kind-control-plane  Created container busybox
  Normal  Started                 5m47s  kubelet, kind-control-plane  Started container busybox
~~~~

~~~~bash
[admin@sandbox kind]$ kubectl get po
NAME                         READY   STATUS    RESTARTS   AGE
csi-hostpath-attacher-0      1/1     Running   0          93s
csi-hostpath-provisioner-0   1/1     Running   0          91s
csi-hostpath-snapshotter-0   1/1     Running   0          90s
csi-hostpath-socat-0         1/1     Running   0          89s
csi-hostpathplugin-0         3/3     Running   0          92s
~~~~



### Задание со звездочкой

1. В отдельной сети (10.51.21.0/24) поднят ISCSI-target.
Структура дисков

~~~~bash
[root@k8s-iscsi ~]# lvs
  LV         VG              Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root       centos_template -wi-ao---- 29,99g
  swap       centos_template -wi-ao----  1,00g
  lv_iscsi   vg_iscsi        -wi-ao----  1,00g
  lv_iscsi-1 vg_iscsi        -wi-ao----  1,00g
  lv_iscsi-2 vg_iscsi        -wi-ao----  1,00g
  lv_iscsi-3 vg_iscsi        -wi-ao----  1,00g
~~~~

Мы будем использовать lv_iscsi-3

2. Настройка ISCSI

Установим утилиту администрирования

~~~~bash
yum install targetcli
~~~~

Добавим диск в хранилище

~~~~bash
[root@k8s-iscsi ~]# targetcli
targetcli shell version 2.1.fb46
Copyright 2011-2013 by Datera, Inc and others.
For help on commands, type 'help'.

/> backstores/block
/backstores/block> create disk04 /dev/vg_iscsi/lv_iscsi-3
Created block storage object disk04 using /dev/vg_iscsi/lv_iscsi-3.
~~~~

Создадим портал

~~~~bash
/backstores/block> cd /iscsi
/iscsi> create iqn.2019-09.ru.k8s:storage.target00
Created target iqn.2019-09.ru.k8s:storage.target00.
Created TPG 1.
Global pref auto_add_default_portal=true
Created default portal listening on all IPs (0.0.0.0), port 3260.
~~~~

Создадим LUN

~~~~bash
Created default portal listening on all IPs (0.0.0.0), port 3260.
/iscsi> cd iqn.2019-09.ru.k8s:storage.target00/tpg1/luns/
/iscsi/iqn.20...t00/tpg1/luns> create /backstores/block/disk00 lun=2
Created LUN 2.
~~~~

Отключим авторизацию (для наших целей в данном ДЗ она не нужна)

~~~~bash
/iscsi/iqn.20...target00/tpg1> set attribute authentication=0
Parameter authentication is now '0'.
~~~~

Обновим ACL (iqn подсмотрим на ноде)

~~~~bash
/iscsi/iqn.20...t01/tpg1/acls> create wwn=iqn.1994-05.com.redhat:ada3b5eb56c
Created Node ACL for iqn.1994-05.com.redhat:ada3b5eb56c
Created mapped LUN 2.
~~~~

Итого, мы настроили iscsi-target, который будет раздавать гигабайтный "диск".

2. Поднимаем кластер.

Поднимаем кластер в Proxmox - один мастер + три воркера.
На узлах поднимаем по два интерфейса: 10.51.21.0/24 и 10.51.21.0/24 (а тут живет iscsi)

3. Подключение volume к pod-у.

Используем конструкцию типа:
~~~~
  volumes:
  - name: iscsipd-rw
    iscsi:
      targetPortal: 10.51.21.101:3260
      iqn: iqn.2019-09.ru.k8s:storage.target01
      fsType: ext4
      lun: 2
      readOnly: false
~~~~

Среди прочего здесь указывается адрес портала, iqn таргет группы и номер Lun. 

Полный манифест: kubernetes-storage/star/iscsi.yaml

После успешного подключения...

~~~~
Events:
  Type    Reason                  Age    From                     Message
  ----    ------                  ----   ----                     -------
  Normal  Scheduled               2m34s  default-scheduler        Successfully assigned default/iscsipd to worker3
  Normal  SuccessfulAttachVolume  2m34s  attachdetach-controller  AttachVolume.Attach succeeded for volume "iscsipd-rw"
  Normal  Pulling                 2m30s  kubelet, worker3         Pulling image "nginx"
  Normal  Pulled                  2m21s  kubelet, worker3         Successfully pulled image "nginx"
  Normal  Created                 2m21s  kubelet, worker3         Created container iscsipd-rw
  Normal  Started                 2m20s  kubelet, worker3         Started container iscsipd-rw
~~~~

...зайдем в контейнер и оставим что-нибдуь в примонтированном каталоге

~~~~bash
[root@master ~]# kubectl exec -it iscsipd -- /bin/bash
root@iscsipd:/# echo "I was here!" > /mnt/iscsipd/data.txt
root@iscsipd:/# more /mnt/iscsipd/data.txt
I was here!
~~~~

4. Снятие snapshot-а

Зайдем на target-хост и сделаем snapshot LVM

~~~~bash
[root@k8s-iscsi ~]# lvcreate --size 1G --snapshot --name log_snap /dev/vg_iscsi/lv_iscsi-3
  Logical volume "log_snap" created.
~~~~

Проверим что получилось:

~~~~bash
[root@k8s-iscsi ~]# lvs
    LV         VG              Attr       LSize  Pool Origin     Data%  Meta%  Move Log Cpy%Sync Convert
    root       centos_template -wi-ao---- 29,99g
    swap       centos_template -wi-ao----  1,00g
    log_snap   vg_iscsi        swi-a-s---  1,00g      lv_iscsi-3 0,01
    lv_iscsi   vg_iscsi        -wi-ao----  1,00g
    lv_iscsi-1 vg_iscsi        -wi-ao----  1,00g
    lv_iscsi-2 vg_iscsi        -wi-ao----  1,00g
    lv_iscsi-3 vg_iscsi        owi-a-s---  1,00g
~~~~

Да, log_snap с нами. Даже видно чего именно это snapshot - lv_iscsi-3

5. Удаление данных.

Вернемся к pod-у - удалим данные в примонтированном каталоге и сам pod:

~~~~bash
[root@master ~]# kubectl exec -it iscsipd -- /bin/bash
root@iscsipd:/# rm -rf /mnt/iscsipd/data.txt
root@iscsipd:/# ls /mnt/iscsipd/
lost+found

[root@master ~]# kubectl delete -f iscsi.yaml
pod "iscsipd" deleted
~~~~

Исключаем том из ISCSI

~~~~bash
/backstores/block> delete disk04
deleted storage object disk04.
~~~~

6. Восстановление данных.

Исполняем команду merge для восстановления тома из snapshot-а (мы отмонтировали его от всего чего можно - ничего не должно помешать)

~~~~bash
[root@k8s-iscsi ~]# lvconvert --merge /dev/vg_iscsi/log_snap
  Merging of volume vg_iscsi/log_snap started.
  vg_iscsi/lv_iscsi-3: Merged: 100,00%
~~~~

Для проверки вернем том в ISCSI, снова поднимем pod и посмотрим что у него внутри:

~~~~bash

/backstores/block> create disk04 /dev/vg_iscsi/lv_iscsi-3
Created block storage object disk04 using /dev/vg_iscsi/lv_iscsi-3.
/backstores/block> cd /iscsi/iqn.2019-09.ru.k8s:storage.target01/tpg1/luns/
/iscsi/iqn.20...t01/tpg1/luns> create /backstores/block/disk04 lun=2
Created LUN 2.


[root@master ~]# kubectl apply -f iscsi.yaml
pod/iscsipd created

[root@master ~]# kubectl exec -it iscsipd -- /bin/bash
root@iscsipd:/# more /mnt/iscsipd/data.txt
I was here!
~~~~

Итак, данные снова доступны!

## Использованные материлы

- https://www.tecmint.com/create-luns-using-lvm-in-iscsi-target/
- https://github.com/kubernetes/examples/tree/master/volumes/iscsi
- https://jnotes.ru/create-lvm-snapshot-and-restore.html
