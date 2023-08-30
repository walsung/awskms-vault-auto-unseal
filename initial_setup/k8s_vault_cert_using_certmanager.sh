#!/bin/bash

sudo mkdir -p /opt/vault/data
sudo mkdir -p /opt/vault/audit
sudo chown -R ubuntu:ubuntu /opt/vault

export VAULT_K8S_NAMESPACE="vault" \
export VAULT_HELM_RELEASE_NAME="vault" \
export VAULT_SERVICE_NAME="vault-internal" \
export K8S_CLUSTER_NAME="cluster.local"

kubectl create ns ${VAULT_K8S_NAMESPACE}
kubectl label ns ${VAULT_K8S_NAMESPACE} istio-injection=enabled

## create a selfsigned-issuer at --namespace="vault"
kubectl apply -f https://gist.githubusercontent.com/t83714/51440e2ed212991655959f45d8d037cc/raw/7b16949f95e2dd61e522e247749d77bc697fd63c/selfsigned-issuer.yaml -n ${VAULT_K8S_NAMESPACE}


## key size: 2048
## PKI needs to renew once per year (8760 hrs = 365 days)
## set to autorotate 15 minutes before expiry date

kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: vault-ha-tls
  namespace: ${VAULT_K8S_NAMESPACE}
spec:
  secretName: vault-ha-tls
  subject:
    organizations:
      - system:nodes
  commonName: system:node:*.${VAULT_K8S_NAMESPACE}.svc.${K8S_CLUSTER_NAME}
  duration: 8760h      # 365d
  renewBefore: 360h    # 15d
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
    rotationPolicy: Always
  usages:
    - digital signature
    - key encipherment
    - server auth
    - client auth
  dnsNames:
    - "*.${VAULT_SERVICE_NAME}"
    - "*.${VAULT_SERVICE_NAME}.${VAULT_K8S_NAMESPACE}.svc.${K8S_CLUSTER_NAME}"
    - "*.${VAULT_K8S_NAMESPACE}"
  ipAddresses:
    - 127.0.0.1
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
EOF



kubectl -n ${VAULT_K8S_NAMESPACE} get secret


