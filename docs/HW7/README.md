# Выполнено ДЗ №6

 - [x] Основное ДЗ
 - [x] Задание со *

## В процессе сделано:

### Задание обычное

1. Установлен Kubectl-debug

Установка плагина

~~~~bash
export PLUGIN_VERSION=0.1.1
# linux x86_64
curl -Lo kubectl-debug.tar.gz https://github.com/aylei/kubectl-debug/releases/download/v${PLUGIN_VERSION}/kubectl-debug_${PLUGIN_VERSION}_linux_amd64.tar.gz

tar -zxvf kubectl-debug.tar.gz kubectl-debug
sudo mv kubectl-debug /usr/local/bin/
~~~~

Установка агента

~~~~bash
kubectl apply -f https://raw.githubusercontent.com/aylei/kubectl-debug/master/scripts/agent_daemonset.yml
~~~~
