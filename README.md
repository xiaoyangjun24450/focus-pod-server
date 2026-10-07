# server

本地开发 + 远程服务器部署的开发工作流。

## 目录结构

```
server/
├── remote-dir/          # 服务器端代码（Go），推送到服务器运行
├── test/                # API 接口测试代码（Python）
├── push.sh              # 将 remote-dir/ 推送到服务器
├── setup-ssh-key.sh     # SSH 免密登录一键配置
├── .deploy.env          # 本地私有配置（含服务器 IP，已被 gitignore）
├── .deploy.env.example  # 配置模板（入库）
└── docs/                # 文档
```

## 首次配置

1. 复制配置模板并填写服务器信息：

   ```bash
   cp .deploy.env.example .deploy.env
   ```

   ```bash
   # .deploy.env
   REMOTE_USER="root"
   REMOTE_HOST="your.server.ip"
   REMOTE_PORT="22"
   REMOTE_PATH="/root/workspace/focus-pod"
   ```

2. 给脚本添加执行权限：

   ```bash
   chmod +x push.sh setup-ssh-key.sh
   ```

3. 配置 SSH 免密登录（只需一次，过程中输入一次密码）：

   ```bash
   ./setup-ssh-key.sh
   ```

## 日常工作流

1. 在 `./remote-dir/` 下编写服务器端代码（Go）
2. 用 `./push.sh` 推送到服务器（rsync 增量同步，自动覆盖远端）
3. SSH 登录服务器运行代码：

   ```bash
   ssh root@<服务器IP>
   cd /root/workspace/focus-pod && go run .
   ```

4. 在本地 `./test/` 下编写 API 接口测试代码（Python）并运行，验证接口

## 说明

- 服务器 IP 等敏感信息统一放在 `.deploy.env`，该文件被 `.gitignore` 忽略，不会入库
- `push.sh` 使用 `--delete` 同步，远端多余文件会被删除，注意不要在服务器上直接修改代码
