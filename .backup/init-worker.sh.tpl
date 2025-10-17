#!/bin/bash

set -e
touch /tmp/init-kubernetes.log
exec > >(tee /tmp/init-kubernetes.log) 2>&1

# --- Pre-setup ---

export HOME=/home/kube
export KUBECONFIG=$HOME/.kube/config

META_TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PRIVATE_IP_DNS=$(curl -s http://169.254.169.254/latest/meta-data/local-hostname -H "X-aws-ec2-metadata-token: $META_TOKEN")
CONTROL_PLANE_IP=${control_plane_ip}
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

### --- Wait for control plane ---

TIMEOUT=180
COUNT=0
until ssh -i "$PRIVATE_KEY_PATH" kube@"$CONTROL_PLANE_IP" -o StrictHostKeyChecking=no "kubectl get nodes" &>/dev/null; do
    echo "Waiting for kube-apiserver on $CONTROL_PLANE_IP..."
    sleep 1
    COUNT=$((COUNT + 1))
    if [ $COUNT -ge $TIMEOUT ]; then
        echo "Timed out after $TIMEOUT seconds waiting for kube-apiserver"
        exit 1
    fi
done

echo "Kube-apiserver is ready!"

### --- Worker setup ---

echo "Joining cluster"

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
  "kubectl label node $PRIVATE_IP_DNS node-role.kubernetes.io/worker="

### --- Copy config files & set permissions ---

echo "Copy config files & set permissions"

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

### --- Config for AWS Cloud Provider ---

mkdir -p /etc/sysconfig
cat <<EOF > /etc/sysconfig/kubelet
[Service]
Environment="KUBELET_EXTRA_ARGS=--cloud-provider=external"
EOF
chown kube:kube /etc/sysconfig/kubelet

systemctl daemon-reload
systemctl restart kubelet

### --- Post-setup ---

rm $PRIVATE_KEY_PATH

echo "Kubernetes setup completed"

exit 0
