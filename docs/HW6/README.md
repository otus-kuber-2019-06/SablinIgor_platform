# Выполнено ДЗ №5

 - [x] Основное ДЗ
 - [x] Задание со *

## В процессе сделано:

### Задание обычное

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

Полный манифест: kubernetes-storage/hw/iscsi.yaml

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
