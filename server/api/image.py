from fastapi import APIRouter
from fastapi.responses import FileResponse
from dto.requests.ImageRequest import ImageRequest
from dto import ImageDto
from services.image import generate_diary_image
from dotenv import load_dotenv
import os

load_dotenv()

image_router = APIRouter(prefix="/image")

@image_router.post("/")
async def generate_image(request: ImageRequest):
    image_dto = ImageDto(
        username=request.username,
        input_word=request.input_word,
        style_word=request.style_word,
        emotion_query=request.emotion_query,
        month=request.month,
        date=request.date,
        style=request.style
    )
    image_path = generate_diary_image(image_dto)
    
    # generate image
    return {
        "image_path": image_path
    }

@image_router.get("/{image_path}")
async def loadImage(image_path: str):
    BASE_IMAGE_PATH = os.getenv("BASE_IMAGE_PATH")
    return FileResponse(BASE_IMAGE_PATH+f'{image_path}')
