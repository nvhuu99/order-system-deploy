Can not use metallb

Let try NGINX Ingress Controller
    https://docs.nginx.com/nginx-ingress-controller/overview/about/

Then AWS Load Balancer Controller

    https://share.google/aimode/jBpkbvAuaU2yjhpWW


    https://devopscube.com/aws-cloud-controller-manager/#step-6-tag-aws-resources

    https://cloud-provider-aws.sigs.k8s.io/
    https://kubernetes.github.io/cloud-provider-aws/getting_started/

    https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/deploy/installation/

    https://jicowan.medium.com/running-flannel-on-eks-9a2f7a285a23
    https://github.com/aws/amazon-vpc-cni-k8s/issues/2839

===
Kubernetes AWS Cloud Provider
    Components:
        AWS Cloud Controller Manager: primarily responsible for creating and updating AWS loadbalancers (classic and NLB) and node lifecycle management
        Volume Plugins: EBS volume plugin