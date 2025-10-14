#!/bin/bash
set -e
cd ~
exec > >(tee /tmp/kube-init.log) 2>&1

### --- Pre-setup ---

echo "Installing network tools and configuring sysctl..."

sudo apt-get update -qq
sudo apt-get install -y conntrack ebtables ethtool socat iproute2 curl tar

sudo modprobe br_netfilter
echo 'br_netfilter' | sudo tee /etc/modules-load.d/k8s.conf > /dev/null

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf > /dev/null
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  
sudo sysctl --system

### --- Install container runtime (containerd) ---

echo "Installing containerd and dependencies..."

# Install runc
sudo curl -Lo /usr/local/sbin/runc https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64
sudo chmod +x /usr/local/sbin/runc

# Install CNI plugins
sudo mkdir -p /opt/cni/bin
curl -LO https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
sudo tar -C /opt/cni/bin -xzvf cni-plugins-linux-amd64-v1.3.0.tgz
rm cni-plugins-linux-amd64-v1.3.0.tgz

# Install containerd
curl -LO https://github.com/containerd/containerd/releases/download/v1.6.2/containerd-1.6.2-linux-amd64.tar.gz
sudo tar -C /usr/local -xzvf containerd-1.6.2-linux-amd64.tar.gz
rm containerd-1.6.2-linux-amd64.tar.gz

sudo mkdir -p /usr/lib/systemd/system
sudo curl -Lo /usr/lib/systemd/system/containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i "s/SystemdCgroup = false/SystemdCgroup = true/" /etc/containerd/config.toml

# Start containerd
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Install crictl
curl -LO https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.28.0/crictl-v1.28.0-linux-amd64.tar.gz
sudo tar -C /usr/bin -xzf crictl-v1.28.0-linux-amd64.tar.gz
rm crictl-v1.28.0-linux-amd64.tar.gz
sudo chmod +x /usr/bin/crictl

### --- Install Kubernetes tools ---

echo "Installing kubeadm, kubelet, kubectl..."

# kubelet
sudo curl -Lo /usr/bin/kubelet https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubelet
sudo chmod +x /usr/bin/kubelet
sudo mkdir -p /var/lib/kubelet
sudo chmod -R 700 /var/lib/kubelet
sudo curl -Lo /etc/systemd/system/kubelet.service https://raw.githubusercontent.com/kubernetes/release/v0.16.2/cmd/krel/templates/latest/kubelet/kubelet.service

# kubeadm
sudo curl -Lo /usr/bin/kubeadm https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubeadm
sudo chmod +x /usr/bin/kubeadm
sudo mkdir -p /etc/systemd/system/kubelet.service.d
sudo curl -Lo /etc/systemd/system/kubelet.service.d/10-kubeadm.conf https://raw.githubusercontent.com/kubernetes/release/v0.16.2/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf

# kubectl
sudo curl -Lo /usr/bin/kubectl https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl
sudo chmod +x /usr/bin/kubectl

# Reload systemd
sudo systemctl daemon-reload
sudo systemctl enable kubelet.service

echo "Kubernetes init setup completed."
