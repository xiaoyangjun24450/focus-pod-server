# FocusPod 后端服务

学习计划后端。当前只实现「获取学习计划列表 / 按 id 获取计划」，后续按 `docs/06-frontend-backend-api.md` 逐步补齐。

## 接口

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/health` | 健康检查 |
| GET | `/api/v1/plans` | 全量学习计划列表，返回 `{ "plans": [...] }` |
| GET | `/api/v1/plans/{planId}` | 单个计划。`planId` **必须是纯数字**（如 `1001`），否则 400；不存在返回 404 |

题目字段与 App 端 `assets/study_plans.json` 完全一致；计划 id 为纯数字：1001 数学 / 1002 语文 / 1003 英语 / 1004 物理 / 1005 化学 / 1006 历史。

## 本地运行

```bash
cd server
python3 -m venv venv
venv/bin/pip install -r requirements.txt
venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
```

打开 http://127.0.0.1:8000/docs 可以直接调试接口。

## 修改题目数据

直接编辑 `data/plans.json`，接口每次请求都会重新读文件，改完即生效，不用重启。

## 部署到云服务器

本仓库是主仓库的 git submodule。用 rsync 同步到云服务器：

```bash
rsync -av --exclude venv --exclude __pycache__ server/ user@服务器:/opt/focus-pod-server/
# 服务器上首次部署：
cd /opt/focus-pod-server && python3 -m venv venv && venv/bin/pip install -r requirements.txt
# 启动（建议用 systemd 或 nohup 托管）：
venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
```

## App 端对接

在 Android 工程的 `local.properties` 里配置：

```properties
server.baseUrl=http://服务器IP:8000
```

不配置时 App 回退读本地 `assets/study_plans.json`。
