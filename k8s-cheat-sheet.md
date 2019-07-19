#Auth (RBAC)

kubectl cluster-info dump | grep authorization-mode

kubectl create serviceaccount foo

kubectl describe sa foo

kubectl create role service-reader --verb=get --verb=list --resource=services --namespace=foo

kubectl create rolebinding test --role=service-reader --serviceaccount=foo:default -n foo

kubectl create clusterrolebinding admin-test --clusterrole=admin --serviceaccount=foo:default

kubectl create clusterrole no-access --verb=[] --resource=[*]
