#!/bin/bash
# https://artifacthub.io/packages/helm/nfs-subdir-external-provisioner/nfs-subdir-external-provisioner
#
# 設定 Helm repo（只需要設定一次，第二次會自動略過）
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/ >/dev/null 2>&1
helm repo update

# 讀取參數或提示輸入
NFS_SERVER="$1"
NFS_PATH="$2"

if [ -z "$NFS_SERVER" ]; then
  read -p "請輸入 NFS Server IP 或 Hostname: " NFS_SERVER
  fi

  if [ -z "$NFS_PATH" ]; then
    read -p "請輸入 NFS 匯出目錄路徑 (例如 /exported/path): " NFS_PATH
    fi

    # 確認輸入
    echo "📦 安裝 nfs-subdir-external-provisioner 至叢集..."
    echo "🔗 NFS Server: $NFS_SERVER"
    echo "📁 NFS Path:   $NFS_PATH"

    # 執行 Helm 安裝
    helm install -n kube-system nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
      --set nfs.server="$NFS_SERVER" \
      --set nfs.path="$NFS_PATH" \
      --set storageClass.defaultClass=true

