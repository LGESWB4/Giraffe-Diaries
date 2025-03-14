from typing import List
from dto.ImageDto import ImageDto
from utils.uuid import make_uuid_with_prefix_and_suffix
from .gpt import translate_to_english

def generate_diary_image(imageDto: ImageDto):
    image_path = generate_image_path(imageDto.username, imageDto.month, imageDto.date)
    
    # 영어로 번역
    translated_words = translate_to_english(imageDto.tokens)
    
    # 이미지 생성
    generate_image_by_SD(translated_words, imageDto.style, image_path)
    
    return image_path
    
def generate_image_path(username: str, month: str, date: str):
    image_path = make_uuid_with_prefix_and_suffix(f"./images/{username}-{month}-{date}", ".png")
    return image_path

def generate_image_by_SD(translated_words: List[str], style: str, image_path: str):
    pass
