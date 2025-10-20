### Refs:

* Karpenter vs Cluster Autoscaler: https://www.youtube.com/watch?v=FIBc8GkjFU0

https://docs.nginx.com/nginx-ingress-controller/configuration/ingress-resources/basic-configuration/

* Tutor: https://www.youtube.com/watch?v=zcA2fRoWlac&list=PLiMWaCMwGJXnKY6XmeifEpjIfkWRo9v2l&index=8

Pod Identity Explain: https://www.youtube.com/watch?v=aUjJSorBE70

https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/service/nlb/

https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md

https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/metrics-collected-by-CloudWatch-agent.html

---

### Modes:

**Standard Mode:**

* AWS only manages control plane
* You have to use eksctl to install bunch of addons, ...
* You have to manage EC2 intances  

**AWS Auto Mode:**

* AWS manages control plane & nodes provisioning, scaling
* Lastest version, AWS provisions nodes with [Karpenter](https://aws.amazon.com/blogs/aws/introducing-karpenter-an-open-source-high-performance-kubernetes-cluster-autoscaler/). Previous version, use `Cluster-Autoscaler`.

---

### Pricing:

+ EKS Standard Support Cost (monthly): 0.1USD per hour -> ~72.00 USD per month
+ EKS Extended Support Cost (monthly): 0.6USD per hour -> ~432.00 USD per month

---

### Concepts:

- Karpenter vs Autoscaler:
  - Autoscaler: you have to create bunch of node groups (template for nodes). You can not be sure that resources are fully utilized or without much redundancy, which is not cost efficient.
  - Karpenter:
    - Auto choose the right instance type when create new node
    - Auto terminate nodes that are resource-redundant, and migrate the pods
    - Auto migrate pod when an upgrade of AMIs are available.
    - You can also fine-grain how to provision nodes, such as limiting the instance types to use.

- Nodegroup:
  - Self-manage: (...)
  - Fargate: (...) 
  - Managed node group:
    - Basically this is Horizontal Autoscaling via NodeGroup
    - You specify the instance type, scaling config, ...

### Networking & Security:

- Requirement:
  - Subnets in at least two AZs.
  - Control plane:
    - assume role principal: `eks.amazonaws.com`
    - policies: `AmazonEKSClusterPolicy`
  - Worker node IAM Policy:
    - assume role principal: `eks.amazonaws.com`
    - policies: `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`

### HA:

- Etcd DB Backup

---

### Usecase:

- Setup IAM User for team member to access the cluster
- Pod Horizontal Autoscaling: helm release metric_server + kube HorizontalPodAutos  caler
- Node Horizontal Autoscaling: use NodeGroup

**AWS Elastic Block Storage CSI**:
  - enable snapshot feature


**Node Load Balancer with use AWS Load Balancer Controller**:
  ...

- Layer 7 Network Load Balancer: For LoadBalancer Service (nlp) 
- Layer 4 Network Load Balancer: For Ingress Service (alp)
- IP Mode: traffic from ALB to Pods directly by ultilzing `secondary ip addresses`. More efficient, less network hop
- Instance Mode: traffic fromm ALB through NodePort then to Pod.

### Extra notes:

**Control Plane:**
  - Cloud Controller Manager: legacy component of k8s for cloud providers to allow calling their API to provision resources for LBs, ...
  - AWS Controllers: migrate from the legacy `Cloud Controller Manager` and no longer part of k8s source code, they are external controllers like the `AWS Load Balancer Controller`, ... 

**Cost control:**
  - Use Spot Instance for batch jobs, or state-less jobs to save cost on EC2.
  - Unless strictly required, try not to deploy services on different AZs as AWS charge more for network. Especially services such as Kafka, Databases... 