#!/run/current-system/sw/bin/bash -x

# usage: ./minikube-helper.sh <docker-image-ver>

: "${1?please supply a vault init wrapper container version}"
INIT_VER=$1
MINIKUBE_PID=$(pidof VBoxHeadless)

minikube delete
rm -rf ~/.minikube/

if [[ -z $MINIKUBE_PID ]]; then
  pkill VBoxHeadless
fi

minikube start
kubectl config use-context minikube
eval "$(minikube docker-env)"
docker build -t vault-go:"${INIT_VER}" .
kubectl create secret generic vault \
  --from-file=ca.pem \
  --from-file=vault.pem \
  --from-file=vault-combined.pem \
  --from-file=vault-key.pem
kubectl create -f vault.yaml
kubectl rollout status statefulset/vault
