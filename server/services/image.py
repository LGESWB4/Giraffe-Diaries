from typing import List
from dto.ImageDto import ImageDto
from utils.uuid import make_uuid_with_prefix_and_suffix
from .gpt import translate_and_generate_prompt
import torch
from diffusers import DiffusionPipeline
import psutil
import time
import gc

def generate_diary_image(imageDto: ImageDto):
    image_path = generate_image_path(imageDto.username, imageDto.month, imageDto.date)
    
    # 영어로 번역
    prompt = translate_and_generate_prompt(imageDto.input_word,imageDto.style_word,imageDto.emotion_query)
    
    # 이미지 생성
    generate_image_by_SD(prompt, imageDto.style_word, imageDto.emotion_query, image_path)
    
    return image_path
    
def generate_image_path(username: str, month: str, date: str):
    image_path = make_uuid_with_prefix_and_suffix(f"./images/{username}-{month}-{date}", ".png")
    return image_path

def generate_image_by_SD(prompt: List[str], style_word: str, emotion_query: str, image_path: str):
    device = "cuda" if torch.cuda.is_available() else "cpu"

    gc.collect()
    torch.cuda.empty_cache()

    pipe = DiffusionPipeline.from_pretrained("stabilityai/stable-diffusion-xl-base-1.0", torch_dtype=torch.float16, use_safetensors=True, variant="fp16")
    pipe.to(device)

    images = pipe(prompt=prompt).images[0]
    images.save(image_path)

    process = psutil.Process()
    memory_usage = process.memory_info().rss / (1024 * 1024)  # Convert to MB
