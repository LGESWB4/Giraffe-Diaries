from typing import List
from dto.ImageDto import ImageDto
from utils.uuid import make_uuid_with_prefix_and_suffix
from dotenv import load_dotenv
from .gpt import translate_and_generate_prompt
import torch
from diffusers import DiffusionPipeline
import psutil
import time
import gc
import os

load_dotenv()

def generate_diary_image(imageDto: ImageDto):    
    # 영어로 번역
    prompt = translate_and_generate_prompt(imageDto.input_word,imageDto.style_word,imageDto.emotion_query)
    
    # 이미지 생성
    generate_image_by_SD(prompt, imageDto.style_word, imageDto.emotion_query, image_path)
    
    return image_path
    
def generate_image_path(username: str, month: str, date: str):
    image_path = make_uuid_with_prefix_and_suffix(f"{username}-{month}-{date}", ".png")
    return image_path

def generate_image_by_SD(prompt: List[str], style_word: str, emotion_query: str, image_path: str):
    BASE_IMAGE_PATH = os.getenv("BASE_IMAGE_PATH")
    output_image_path = BASE_IMAGE_PATH+image_path
    device = "cuda" if torch.cuda.is_available() else "cpu"

    gc.collect()
    torch.cuda.empty_cache()

    pipe = DiffusionPipeline.from_pretrained("stabilityai/stable-diffusion-xl-base-1.0", torch_dtype=torch.float16, use_safetensors=True, variant="fp16")
    pipe.to(device)

    images = pipe(prompt=prompt).images[0]
    images.save(output_image_path)

    process = psutil.Process()
    memory_usage = process.memory_info().rss / (1024 * 1024)  # Convert to MB
