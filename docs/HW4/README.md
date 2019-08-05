### [return...](../../README.md)

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

### [return...](../../README.md)
