# Refs:
    
**container-runtimes guide:**           
https://kubernetes.io/docs/setup/production-environment/container-runtimes/

**container-runtimes install guide:**   
https://github.com/containerd/containerd/blob/main/docs/getting-started.md
https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md

**kubectl install gude:**           
https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

**kubeadm, kubelet install gude:** 
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

**troubleshooting:**    
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/

# Setup kubernetes nodes:

**Optional - set node names (before join cluster)**

    sudo hostnamectl set-hostname <master|worker-1|worker-2>
    sudo vim /etc/hosts
    172.31.9.49 master
    172.31.5.229 worker1
    172.31.1.216 worker2

**Copy and run the script on nodes:** 
    
    `setup-k8s-node.sh`

# On Master node - Init cluster:

**Init cluster**
    Remember to save the "join command", later run that on worker node to add it to the cluster
    
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16

**Without this, kubectl might not work properly**
    
    mkdir -p $HOME/.kube && \
    sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config && \
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    
**Install pod network addons**
    
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# On Worker node - Join cluster:

**Join cluster**
    Use the output command when you run "cluster init" on master

    sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# Optional - Label worker nodes:
    
After all nodes added, you can run this on the master node:

    kubectl label node <worker-node> node-role.kubernetes.io/worker=

### Troubleshooting:

**Reset worker node to clean state** 
sudo kubeadm reset -f && \
sudo systemctl stop kubelet && \
sudo rm -rf /etc/kubernetes /var/lib/kubelet /var/lib/cni /etc/cni && \
sudo mkdir -p /var/lib/kubelet
