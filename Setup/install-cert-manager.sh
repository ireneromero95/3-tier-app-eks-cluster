#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="eks-cluster-irene-and-joao"
ACCOUNT_ID="686699774218"
CERT_MANAGER_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/CertManagerRole-${CLUSTER_NAME}"

helm repo add jetstack https://charts.jetstack.io
helm repo update jetstack

helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.2 \
  --set crds.enabled=true \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="${CERT_MANAGER_ROLE_ARN}" \
  --wait --timeout=5m

echo ""
echo "==> cert-manager installed for ${CLUSTER_NAME}."
kubectl get pods -n cert-manager