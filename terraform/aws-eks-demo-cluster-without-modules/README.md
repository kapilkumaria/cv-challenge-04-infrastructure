# aws-eks-demo-cluster-without-modules

# Author : Khaja Ehteshamuddin Ahmed

This Repo is used for creation of the EKS Cluster on AWS Infrastructure. 


You can modify the vpc and subnet CIDRS in the terraform.tfvars file as per your requirements. other values such as cluster version, instances type in the nodegroup can be changed.


In the kubernetes.tf file, i have provided user devops access to the kubernetes resources, as by default i am not having access to cluster.


==

There are two files role.yaml and rolebinding.yaml for providing user RBAC to the resources inside the cluster, you can customize it with your user names.

==