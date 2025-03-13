from fastapi import FastAPI
from fastapi.responses import FileResponse
from services.gpt import translate_to_english
from api import image_router

app = FastAPI()

app.include_router(image_router)
