#!/usr/bin/env bash
# 推送 remote-dir/ 到服务器（服务器信息从 .deploy.env 读取）
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

rsync -avz --delete -e "ssh -p ${REMOTE_PORT}" \
    "${SCRIPT_DIR}/remote-dir/" \
    "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"
