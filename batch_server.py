# batch_server.py
import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Any
import laya

app = FastAPI()
agent = None


@app.on_event("startup")
def load_model():
    global agent
    agent = laya.load("convaiinnovations/laya")  # single checkpoint, loaded once


class BatchRequest(BaseModel):
    states: list[dict[str, Any]]
    questions: dict[str, Any]


@app.post("/v1/batch")
def batch_predict(req: BatchRequest):
    if agent is None:
        raise HTTPException(status_code=503, detail="model not loaded")
    return {"results": agent.predict_batch(req.states, req.questions)}


@app.get("/healthz")
def healthz():
    return {"status": "ok"}
