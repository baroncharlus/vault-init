#!/run/current-system/sw/bin/bash -x

# usage: ./minikube-helper.sh <docker-image-ver>

: "${1?please supply a vault version}"
VAULT_VER=$1
MINIKUBE_PID=$(pidof VBoxHeadless)

minikube delete
rm -rf ~/.minikube

if [[ -z $MINIKUBE_PID ]]; then
  pkill VBoxHeadless
fi

minikube start
kubectl config use-context minikube
eval "$(minikube docker-env)"
docker build -t vault-go:"${VAULT_VER}" .
kubectl create -f vault.yaml
kubectl rollout status deployment/vault
