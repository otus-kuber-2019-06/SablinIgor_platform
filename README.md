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
