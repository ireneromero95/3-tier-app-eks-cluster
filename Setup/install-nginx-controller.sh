#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="eks-cluster-irene-and-joao"
ACCOUNT_ID="686699774218"

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update ingress-nginx

helm upgrade --install joao-and-irene ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="nlb" \
  --wait --timeout=5m

echo ""
echo "==> nginx ingress controller installed for ${CLUSTER_NAME}."
kubectl get pods -n ingress-nginx
kubectl get service -n ingress-nginx