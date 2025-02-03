provider "kubernetes" {
  config_path = pathexpand("~/.kube/config") # ✅ Uses generated kubeconfig
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config") # ✅ Uses generated kubeconfig
  }
}

# Ensure Terraform waits for the EKS cluster before deploying Helm resources
data "aws_eks_cluster" "eks" {
  name = "eks-cluster" # Must match the name in eks-cluster.tf
}

data "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.main.name  # Ensure this matches your EKS cluster
  node_group_name = aws_eks_node_group.main.node_group_name # Ensure this matches your Node Group

  depends_on = [aws_eks_node_group.main] # ✅ Ensures Terraform waits for the Node Group
}


data "aws_eks_cluster_auth" "eks" {
  name = "eks-cluster"
}



# Ensure EKS Nodes are ready before deploying workloads
resource "time_sleep" "wait_for_eks_nodes" {
  depends_on      = [data.aws_eks_node_group.eks_nodes]
  create_duration = "90s"
}

# Create Kubernetes Namespace for Elastic Stack
resource "kubernetes_namespace" "elastic_stack" {
  metadata {
    name = "elastic-stack"
  }

  depends_on = [data.aws_eks_cluster.eks] # Ensure EKS is ready
}

# Ensure Helm repository is updated before deploying charts
resource "null_resource" "helm_repo_update" {
  provisioner "local-exec" {
    command = "helm repo add elastic https://helm.elastic.co && helm repo update"
  }

  depends_on = [data.aws_eks_cluster.eks]
}

# Generate kubeconfig to access Kubernetes API
resource "local_file" "kubeconfig" {
  filename = pathexpand("~/.kube/config")
  content  = <<EOF
apiVersion: v1
clusters:
- cluster:
    server: ${data.aws_eks_cluster.eks.endpoint}
    certificate-authority-data: ${data.aws_eks_cluster.eks.certificate_authority[0].data}
  name: ${data.aws_eks_cluster.eks.name}
contexts:
- context:
    cluster: ${data.aws_eks_cluster.eks.name}
    user: ${data.aws_eks_cluster.eks.name}
  name: ${data.aws_eks_cluster.eks.name}
current-context: ${data.aws_eks_cluster.eks.name}
kind: Config
preferences: {}
users:
- name: ${data.aws_eks_cluster.eks.name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - eks
        - get-token
        - --region
        - ${var.aws_region}
        - --cluster-name
        - ${data.aws_eks_cluster.eks.name}
EOF

  depends_on = [data.aws_eks_cluster.eks] # Waits for EKS before writing kubeconfig
}

# Set kubeconfig environment variable
resource "null_resource" "set_kubeconfig" {
  provisioner "local-exec" {
    command = "export KUBECONFIG=~/.kube/config"
  }

  depends_on = [local_file.kubeconfig]
}

# Deploy Elasticsearch using Helm
resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  namespace  = kubernetes_namespace.elastic_stack.metadata[0].name
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "8.5.1"
  timeout    = 600  # Increase timeout to 10 minutes

  values = [
    <<EOF
clusterName: "elasticsearch"
nodeGroup: "master"
replicas: 1
minimumMasterNodes: 1
volumeClaimTemplate:
  accessModes: [ "ReadWriteOnce" ]
  storageClassName: "gp2-immediate"
  resources:
    requests:
      storage: 5Gi
resources:
  requests:
    cpu: "500m"
    memory: "1Gi"  # Reduced for test purposes
  limits:
    cpu: "1000m"
    memory: "2Gi"
service:
  type: NodePort
  ports:
    - name: http
      port: 9200
      nodePort: 30200
    - name: transport
      port: 9300
      nodePort: 30300
esJavaOpts: "-Xms1g -Xmx1g"  # Adjusted to match memory limits
EOF
  ]

  # Wait for CSI driver and node readiness
  depends_on = [
    helm_release.aws_ebs_csi_driver,
    time_sleep.wait_for_eks_nodes
  ]
}

# Deploy Fluentd using Helm
resource "helm_release" "fluentd" {
  name       = "fluentd"
  namespace  = kubernetes_namespace.elastic_stack.metadata[0].name
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluentd"
  version    = "0.3.0"

  values = [
    <<EOF
daemonset:
  enabled: true
  tolerations:
    - key: "node-role.kubernetes.io/master"
      effect: NoSchedule
fluentd:
  output:
    type: "elasticsearch"
    host: "elasticsearch.elastic-stack.svc.cluster.local"
    port: 9200
    logstash_format: true
EOF
  ]

  depends_on = [helm_release.elasticsearch] # Ensure Elasticsearch is ready before Fluentd
}

# Deploy Kibana using Helm
resource "helm_release" "kibana" {
  name       = "kibana"
  namespace  = kubernetes_namespace.elastic_stack.metadata[0].name
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "8.5.1" # ✅ Match Elasticsearch version

  values = [
    <<EOF
replicaCount: 1
elasticsearchHosts: "http://elasticsearch.elastic-stack.svc.cluster.local:9200"
service:
  type: NodePort
  nodePort: 30601
EOF
  ]

  depends_on = [helm_release.elasticsearch] # Ensure Elasticsearch is available before Kibana
}
