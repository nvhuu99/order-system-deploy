#!/bin/bash

set -e
touch /tmp/init-kubernetes.log
exec > >(tee /tmp/init-kubernetes.log) 2>&1

### --- Pre-setup ---

export HOME=/home/kube
export KUBECONFIG=$HOME/.kube/config

META_TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PRIVATE_IP_DNS=$(curl -s http://169.254.169.254/latest/meta-data/local-hostname -H "X-aws-ec2-metadata-token: $META_TOKEN")
PRIVATE_KEY_PATH=/tmp/temp_key.pem

hostnamectl set-hostname $PRIVATE_IP_DNS

cat <<EOF > $PRIVATE_KEY_PATH
${openssh_private_key}
EOF
chmod 600 $PRIVATE_KEY_PATH

### --- Create "kube" user ---

echo "Creating \"kube\" user"

useradd -m -s /bin/bash kube
echo "kube:${kube_usr_pwd}" | chpasswd

mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh
chown kube:kube $HOME/.ssh

PUB_KEY=$(ssh-keygen -y -f "$PRIVATE_KEY_PATH")
echo "$PUB_KEY" | tee -a "$HOME/.ssh/authorized_keys" >/dev/null
chmod 600 "$HOME/.ssh/authorized_keys"
chown kube:kube "$HOME/.ssh/authorized_keys"

### --- Control plane setup ---

echo "Running \"kubeadm init\""

kubeadm init --pod-network-cidr=${pod_network_cidr}

### --- Copy config files & set permissions ---

echo "Copy config files & set permissions"

mkdir -p $HOME/.kube
echo "export HOME=$HOME" >> $HOME/.bashrc
echo "export KUBECONFIG=$KUBECONFIG" >> $HOME/.bashrc
echo "export HOME=$HOME" >> /root/.bashrc
echo "export KUBECONFIG=$KUBECONFIG" >> /root/.bashrc
cp /etc/kubernetes/admin.conf $KUBECONFIG

chown -R kube:kube $HOME
chown -R kube:kube /var/lib/kubelet
chown -R kube:kube /etc/kubernetes
chmod -R 750 /var/lib/kubelet
chmod -R 750 /etc/kubernetes

### --- Config for AWS Cloud Provider ---

cp /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml.bak
cp /etc/kubernetes/manifests/kube-controller-manager.yaml /etc/kubernetes/manifests/kube-controller-manager.yaml.bak

sed -i '/^    - kube-apiserver$/a\    - --cloud-provider=external' \
    /etc/kubernetes/manifests/kube-apiserver.yaml

sed -i '/^    - kube-controller-manager$/a\    - --cloud-provider=external' \
    /etc/kubernetes/manifests/kube-controller-manager.yaml

systemctl daemon-reload
systemctl restart kubelet

### --- Installing Addons ---

# echo "Installing kubernetes addons"

# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

### --- Installing Helm ---

apt-get update && apt-get install curl gpg apt-transport-https --yes
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update && apt-get install helm --yes

### --- Post-setup ---

rm $PRIVATE_KEY_PATH

echo "Kubernetes setup completed"

exit 0
