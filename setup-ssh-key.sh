#!/usr/bin/env bash
# SSH 免密登录一键配置脚本
# 用法: ./setup-ssh-key.sh [端口]
# 服务器信息从 .deploy.env 读取

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.deploy.env"

if [[ ! -f "${ENV_FILE}" ]]; then
    echo "错误: 未找到 ${ENV_FILE}"
    echo "请先复制模板并填写: cp .deploy.env.example .deploy.env"
    exit 1
fi

# shellcheck source=.deploy.env
source "${ENV_FILE}"

REMOTE="${REMOTE_USER}@${REMOTE_HOST}"
PORT="${1:-${REMOTE_PORT}}"
KEY_TYPE="ed25519"
KEY_FILE="$HOME/.ssh/id_${KEY_TYPE}"

echo "==> 目标: ${REMOTE} (端口 ${PORT})"

# 1. 检查 ssh-keygen 是否可用
command -v ssh-keygen >/dev/null || { echo "错误: 未安装 ssh-keygen"; exit 1; }

# 2. 生成密钥（已存在则跳过）
if [[ -f "${KEY_FILE}" ]]; then
    echo "==> 已存在密钥 ${KEY_FILE}，跳过生成"
else
    echo "==> 生成 ${KEY_TYPE} 密钥（passphrase 留空以保证免密）"
    ssh-keygen -t "${KEY_TYPE}" -f "${KEY_FILE}" -N "" -C "${USER}@$(hostname)"
fi

# 3. 将公钥追加到服务器 authorized_keys
echo "==> 上传公钥到 ${REMOTE}（需要输入一次密码）"
if command -v ssh-copy-id >/dev/null; then
    ssh-copy-id -i "${KEY_FILE}.pub" -p "${PORT}" "${REMOTE}"
else
    cat "${KEY_FILE}.pub" | ssh -p "${PORT}" "${REMOTE}" \
        "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
fi

# 4. 验证免密登录
echo "==> 验证免密登录..."
if ssh -p "${PORT}" -o BatchMode=yes -o ConnectTimeout=10 "${REMOTE}" "echo ok" >/dev/null 2>&1; then
    echo "✅ 免密配置成功: ${REMOTE}"
else
    echo "❌ 免密验证失败，请检查:"
    echo "   - 服务器 ~/.ssh 权限须为 700, authorized_keys 须为 600"
    echo "   - 服务器家目录不能对组/其他人可写 (chmod g-w,o-w ~)"
    echo "   - 服务器 sshd 配置是否禁用了 PublicKeyAuthentication"
    exit 1
fi
