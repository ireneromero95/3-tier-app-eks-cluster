#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="eks-cluster-irene-and-joao"
ACCOUNT_ID="686699774218"
EXTERNAL_DNS_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/ExternalDNSRole-${CLUSTER_NAME}"
HOSTED_ZONE_ID="Z042372728MB5VI4H04IG"

helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update external-dns

helm upgrade --install external-dns external-dns/external-dns \
  --namespace external-dns \
  --create-namespace \
  --set provider=aws \
  --set aws.zoneType=public \
  --set txtOwnerId="${HOSTED_ZONE_ID}" \
  --set domainFilters[0]=ironlabs.online \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="${EXTERNAL_DNS_ROLE_ARN}" \
  --wait --timeout=5m

echo ""
echo "==> external-dns installed for ${CLUSTER_NAME}."
kubectl get pods -n external-dns