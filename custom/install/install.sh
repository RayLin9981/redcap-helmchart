#!/usr/bin/env bash
set -euo pipefail

# === 可自訂參數 ===
export NAMESPACE="temp"
export REDCAP_VERSION="15.3.0"

# #/redcap_upgrade_${REDCAP_VERSION}.zip
# #/redcap_full_${REDCAP_VERSION}.zip
# 檢查 values.yaml 版本
# cat ./values.yaml| grep version

# 建立 namespace 與社群版登入憑證
kubectl create namespace "${NAMESPACE}" || true
kubectl -n "${NAMESPACE}" create secret generic redcap-community-credentials \
  --from-literal USERNAME='my-username' \
  --from-literal PASSWORD='my-password' \
  --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install -n "${NAMESPACE}" redcap ../../charts/redcap/ \
  -f ./values.yaml \

# 上傳 REDCap ZIP 安裝包
kubectl cp -n "${NAMESPACE}" ./redcap.zip \
  "$(kubectl get pods -n "${NAMESPACE}" -l "app.kubernetes.io/name"=redcap -o jsonpath='{.items[0].metadata.name}')":/tmp/redcap/redcap_full_${REDCAP_VERSION}.zip \
  -c init-download-redcap

# 等待 安裝完畢，

# 部署 Nginx
# 建立憑證 kubectl -n "${NAMESPACE}"
kubectl -n "${NAMESPACE}" apply -f nginx
# kubectl patch ingress redcap -n ${NAMESPACE} \
#  --type='json' \
#  -p='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/name", "value": "redcap-nginx-svc"}]'


kubectl -n "${NAMESPACE}" rollout restart deployment redcap

