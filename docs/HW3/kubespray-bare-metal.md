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

## Удалить кластер
-  в каталоге infra/scaleway запусить: terraform destroy --auto-approve
