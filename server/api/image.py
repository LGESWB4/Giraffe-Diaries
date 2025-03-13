from fastapi import APIRouter
from fastapi.responses import FileResponse
from dto.requests.ImageRequest import ImageRequest
from dto import ImageDto
from services.image import generate_image_path
from services.gpt import translate_to_english

image_router = APIRouter()

@image_router.post("/image")
async def generate_image(request: ImageRequest):
    # 받은 토큰들을 처리
    received_tokens = request.tokens
    image_dto = ImageDto(
        username=request.username,
        tokens=request.tokens,
        month=request.month,
        date=request.date
    )
    image_path = generate_image_path(image_dto)
    
    return {
        "image_path": image_path
    }

@image_router.get("/mother")
async def loadImage():
    return FileResponse('./images/mother.png')
