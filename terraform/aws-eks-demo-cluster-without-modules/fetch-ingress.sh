#!/bin/bash
INGRESS_NAME="argocd-ingress"
NAMESPACE="argocd"

# Get the Load Balancer hostname from Kubernetes Ingress
LB_HOSTNAME=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Return JSON output for Terraform
if [[ -z "$LB_HOSTNAME" ]]; then
  echo "{\"hostname\": \"\"}"
else
  echo "{\"hostname\": \"$LB_HOSTNAME\"}"
fi
