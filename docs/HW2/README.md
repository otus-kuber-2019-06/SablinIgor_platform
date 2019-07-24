### [return...](../../README.md)

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

### [return...](../../README.md)
