from fastapi import APIRouter
from fastapi.responses import FileResponse
from dto.requests.ImageRequest import ImageRequest
from dto import ImageDto
from services.image import generate_diary_image
from services.gpt import translate_to_english

image_router = APIRouter(prefix="/image")

@image_router.post("/")
async def generate_image(request: ImageRequest):
    image_dto = ImageDto(
        username=request.username,
        tokens=request.tokens,
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
    return FileResponse(f'./images/{image_path}.png')
