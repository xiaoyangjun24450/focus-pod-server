#!/bin/bash
# 服务器环境初始化脚本（Ubuntu x86_64）
set -e

GO_VERSION=1.23.0

echo "=== 1. 安装基础工具 ==="
apt update
apt install -y wget tar sqlite3 ufw

echo "=== 2. 安装 Go $GO_VERSION ==="
if command -v go > /dev/null; then
    echo "Go 已安装: $(go version)"
else
    wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz
    rm -rf /usr/local/go
    tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
    grep -q '/usr/local/go/bin' ~/.bashrc || echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    export PATH=$PATH:/usr/local/go/bin
    echo "Go 安装完成: $(go version)"
fi

echo "=== 3. 配置防火墙 ==="
ufw allow 22/tcp || true
ufw allow 6020/tcp || true
ufw --force enable
ufw status

echo "=== 4. 创建工作目录 ==="
mkdir -p /root/workspace/focus-pod

echo "=== 完成 ==="
echo "注意：如仍无法访问 6020 端口，请到阿里云控制台安全组放行 6020/tcp"
