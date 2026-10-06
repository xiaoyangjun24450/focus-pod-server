"""FocusPod 学习计划后端服务。

提供两个接口：
- GET /api/v1/plans           学习计划列表
- GET /api/v1/plans/{planId}  按 id 获取单个计划，planId 必须是纯数字

本地启动：uvicorn main:app --host 0.0.0.0 --port 8000
接口文档：http://127.0.0.1:8000/docs
"""
import json
import re
from pathlib import Path

from fastapi import FastAPI, HTTPException

DATA_FILE = Path(__file__).resolve().parent / "data" / "plans.json"
PLAN_ID_PATTERN = re.compile(r"^[0-9]+$")

app = FastAPI(title="FocusPod Study Plan API", version="0.1.0")


def load_plans() -> list:
    """每次请求都重新读文件，rsync 更新 data/plans.json 后无需重启服务。"""
    with DATA_FILE.open(encoding="utf-8") as f:
        return json.load(f)["plans"]


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/api/v1/plans")
def list_plans():
    return {"plans": load_plans()}


@app.get("/api/v1/plans/{plan_id}")
def get_plan(plan_id: str):
    if not PLAN_ID_PATTERN.fullmatch(plan_id):
        raise HTTPException(status_code=400, detail="planId 必须是纯数字")
    plan = next((p for p in load_plans() if p["id"] == plan_id), None)
    if plan is None:
        raise HTTPException(status_code=404, detail="学习计划不存在")
    return plan
