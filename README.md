# vault-init

Adapting Kelsey Hightower's vault on kubernetes to run in minikube for a PoC.

Also uses big chunks of the vault-init code in a sidecar container, but gets 
rid of the GCP dependencies and keeps everything in memory for demo purposes.

You'll need to follow the same cert creation steps in the parent repo to get
things working.

_Not_ prod worthy.

sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/gp-f-rhel-7-server-extras-rpms.repo

sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2 -y

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo -y

yum list docker-ce --showduplicates | sort -r

sudo yum install docker-ce-17.03.2.ce-1.el7.centos -y

sudo systemctl start docker && systemctl enable docker

sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet

sysctl -w net.ipv4.ip_forward=1

/etc/sysctl.conf:
net.ipv4.ip_forward = 1

swapoff -a

sudo tee /etc/sysctl.d/k8s.conf > /dev/null <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

++++

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

~~~~~~

# flannel:
sysctl net.bridge.bridge-nf-call-iptables=1
kubeadm init --apiserver-advertise-address=0.0.0.0 --pod-network-cidr=10.244.0.0/16
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml

# enable single vm env:
kubectl taint nodes --all node-role.kubernetes.io/master-

~~~~~~

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

cfssl gencert -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname="vault,vault.default.svc.cluster.local,localhost,127.0.0.1" \
  -profile=default \
  vault-csr.json | cfssljson -bare vault

cat vault.pem ca.pem > vault-combined.pem

kubectl create secret generic vault \
  --from-file=ca.pem \
  --from-file=vault.pem \
  --from-file=vault-combined.pem \
  --from-file=vault-key.pem

# the name between the two = is the name we'll use to access the secret on the
# mount

kubectl create secret generic svc \
  --from-file=key.json=/home/elliot_wright/vault-init/svc.json

  kubectl create configmap vault \
--from-literal gcs-bucket-name=prj-gousenaid-vaul-str01


