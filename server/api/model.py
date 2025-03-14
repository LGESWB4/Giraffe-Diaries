from fastapi import APIRouter
from fastapi.responses import FileResponse

model_router = APIRouter(prefix="/model")

@model_router.post("/")
async def download_image():
    return FileResponse('./model/Llama-3.2-3B-Instruct-BF16.gguf', filename="Llama-3.2-3B-Instruct-BF16.gguf", media_type="application/octet-stream")
