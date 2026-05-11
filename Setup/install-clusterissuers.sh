#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="us-east-1"
HOSTED_ZONE_ID="Z042372728MB5VI4H04IG"   # ironlabs.online
ACME_EMAIL="finkry@gmail.com"             # Let's Encrypt account email

# ── Staging issuer ─────────────────────────────────────────────────────────────
echo "==> Creating letsencrypt-staging ClusterIssuer..."
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${ACME_EMAIL}
    privateKeySecretRef:
      name: letsencrypt-staging-key
    solvers:
      - dns01:
          route53:
            region: ${AWS_REGION}
            hostedZoneID: ${HOSTED_ZONE_ID}
EOF

# ── Production issuer ─────────────────────────────────────────────────────────
echo "==> Creating letsencrypt-prod ClusterIssuer..."
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${ACME_EMAIL}
    privateKeySecretRef:
      name: letsencrypt-prod-key
    solvers:
      - dns01:
          route53:
            region: ${AWS_REGION}
            hostedZoneID: ${HOSTED_ZONE_ID}
EOF

echo ""
echo "==> ClusterIssuers created. Waiting for ACME registration..."
kubectl wait clusterissuer letsencrypt-staging letsencrypt-prod \
  --for=condition=Ready --timeout=60s

kubectl get clusterissuer