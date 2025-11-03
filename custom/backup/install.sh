#!/bin/bash

NAMESPACE=${NAMESPACE:-redcap}  # 可透過環境變數指定，預設 redcap
echo "部署資源到 namespace: $NAMESPACE"

kubectl apply -n ${NAMESPACE} -f  ./yaml
kubectl apply -n ${NAMESPACE} -f  ./pvc
