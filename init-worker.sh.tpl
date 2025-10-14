#!/bin/bash

set -e
touch /tmp/init-kubernetes.log
exec > >(tee /tmp/init-kubernetes.log) 2>&1

# --- Pre-setup ---

hostnamectl set-hostname ${hostname}

export HOME=/home/kube
export KUBECONFIG=$HOME/.kube/config
export CONTROL_PLANE_IP=${control_plane_ip}
export PRIVATE_KEY_PATH=/tmp/temp_key.pem

cat <<EOF > $PRIVATE_KEY_PATH
${openssh_private_key}
EOF
chmod 600 $PRIVATE_KEY_PATH

### --- Create "kube" user ---

echo "--- Creating \"kube\" user ---"

useradd -m -s /bin/bash kube
echo "kube:${kube_usr_pwd}" | chpasswd

mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh
chown kube:kube $HOME/.ssh

PUB_KEY=$(ssh-keygen -y -f "$PRIVATE_KEY_PATH")
echo "$PUB_KEY" | tee -a "$HOME/.ssh/authorized_keys" >/dev/null
chmod 600 "$HOME/.ssh/authorized_keys"
chown kube:kube "$HOME/.ssh/authorized_keys"

### --- Worker setup ---

echo "--- Joining cluster ---"

export TOKEN=$(ssh -i $PRIVATE_KEY_PATH kube@$CONTROL_PLANE_IP -o StrictHostKeyChecking=no \
  "kubeadm token create")

export CERT_HASH=$(ssh -i $PRIVATE_KEY_PATH kube@$CONTROL_PLANE_IP \
  "openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | \
   openssl rsa -pubin -outform der 2>/dev/null | \
   sha256sum | awk '{print \$1}'")

kubeadm join $CONTROL_PLANE_IP:6443 \
  --token $TOKEN \
  --discovery-token-ca-cert-hash sha256:$CERT_HASH

ssh -i $PRIVATE_KEY_PATH kube@$CONTROL_PLANE_IP \
  "kubectl label node ${hostname} node-role.kubernetes.io/worker="

### --- Copy config files & set permissions ---

echo "--- Copy config files & set permissions ---"

mkdir -p $HOME/.kube
echo "export HOME=$HOME" >> $HOME/.bashrc
echo "export KUBECONFIG=$KUBECONFIG" >> $HOME/.bashrc
echo "export HOME=$HOME" >> /root/.bashrc
echo "export KUBECONFIG=$KUBECONFIG" >> /root/.bashrc
cp /etc/kubernetes/kubelet.conf $KUBECONFIG

chown -R kube:kube $HOME
chown -R kube:kube /var/lib/kubelet
chown -R kube:kube /etc/kubernetes
chmod -R 750 /var/lib/kubelet
chmod -R 750 /etc/kubernetes

### --- Post-setup ---

rm $PRIVATE_KEY_PATH

echo "--- Kubernetes setup completed ---"

exit 0
