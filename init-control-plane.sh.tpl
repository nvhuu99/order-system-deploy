#!/bin/bash

set -e
touch /tmp/init-kubernetes.log
exec > >(tee /tmp/init-kubernetes.log) 2>&1

### --- Pre-setup ---

hostnamectl set-hostname ${hostname}

export HOME=/home/kube
export KUBECONFIG=$HOME/.kube/config
export PRIVATE_KEY_PATH=/tmp/temp_key.pem

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

echo "--- Running \"kubeadm init\" ---"

kubeadm init --pod-network-cidr=${pod_network_cidr}

### --- Copy config files & set permissions ---

echo "--- Copy config files & set permissions ---"

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

echo "--- Installing kubernetes addons ---"

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

rm $PRIVATE_KEY_PATH

echo "--- Kubernetes setup completed ---"

exit 0
