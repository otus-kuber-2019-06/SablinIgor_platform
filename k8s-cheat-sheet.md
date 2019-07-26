#Auth (RBAC)

kubectl cluster-info dump | grep authorization-mode

kubectl config view

kubectl config view -o jsonpath='{.users[].name}'    # get a list of users

kubectl config get-contexts                          # display list of contexts 

kubectl config current-context			               # display the current-context

kubectl config use-context my-cluster-name           # set the default context to my-cluster-name

kubectl create serviceaccount foo

kubectl describe sa foo

kubectl create role service-reader --verb=get --verb=list --resource=services --namespace=foo

kubectl create rolebinding test --role=service-reader --serviceaccount=foo:default -n foo

kubectl create clusterrolebinding admin-test --clusterrole=admin --serviceaccount=foo:default

kubectl create clusterrole no-access --verb=[] --resource=[*]
