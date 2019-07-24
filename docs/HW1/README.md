### [return...](../../README.md)

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

### [return...](../../README.md)
