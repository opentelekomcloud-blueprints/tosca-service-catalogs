#!/bin/bash
set -euo pipefail

NAMESPACE="qdrant"
TIMEOUT=600  # 10 minutes in seconds
INTERVAL=5

# --- Step 1: Wait for EXTERNAL-IP with timeout ---
echo "Waiting for ELB IP (timeout: ${TIMEOUT}s)..."
ELAPSED=0
while true; do
  EXTERNAL_IP=$(kubectl get svc qdrant -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
  if [[ -n "$EXTERNAL_IP" ]]; then
    break
  fi
  if [[ $ELAPSED -ge $TIMEOUT ]]; then
    echo "ERROR: Timed out waiting for EXTERNAL-IP after ${TIMEOUT}s"
    exit 1
  fi
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done
echo "ELB IP: $EXTERNAL_IP"

# --- Step 2: Generate self-signed certificate ---
openssl req -x509 -nodes -days 365 \
  -newkey rsa:4096 \
  -keyout /tmp/tls.key \
  -out /tmp/tls.crt \
  -subj "/CN=qdrant" \
  -addext "subjectAltName=IP:${EXTERNAL_IP}" 2>/dev/null

# --- Step 3: Create TLS secret ---
kubectl create secret tls qdrant-tls-secret \
  -n "$NAMESPACE" \
  --cert=/tmp/tls.crt \
  --key=/tmp/tls.key \
  --dry-run=client -o yaml | kubectl apply -f -

# --- Step 4: Patch ArgoCD Application to enable TLS ---
kubectl -n argocd patch application qdrant --type merge -p '
{
  "spec": {
    "source": {
      "helm": {
        "parameters": [
          {"name": "config.service.enable_tls", "value": "true"},
          {"name": "config.tls.cert", "value": "/qdrant/tls/tls.crt"},
          {"name": "config.tls.key", "value": "/qdrant/tls/tls.key"},
          {"name": "additionalVolumes[0].name", "value": "qdrant-tls"},
          {"name": "additionalVolumes[0].secret.secretName", "value": "qdrant-tls-secret"},
          {"name": "additionalVolumeMounts[0].name", "value": "qdrant-tls"},
          {"name": "additionalVolumeMounts[0].mountPath", "value": "/qdrant/tls"},
          {"name": "additionalVolumeMounts[0].readOnly", "value": "true"}
        ]
      }
    }
  }
}'

# --- Cleanup ---
rm -f /tmp/tls.crt /tmp/tls.key

echo "Done! TLS enabled for qdrant"
echo "Access https://$EXTERNAL_IP:6333/dashboard"