from fastapi import APIRouter
from fastapi.responses import FileResponse

model_router = APIRouter(prefix="/model")

@model_router.post("/{file_name}")
async def download_image(file_name: str):
    return FileResponse(f'./model/{file_name}', filename=file_name, media_type="application/octet-stream")
