from dto.ImageDto import ImageDto
from utils.uuid import make_uuid_with_prefix_and_suffix

def generate_diary_image(imageDto: ImageDto):
    image_path = generate_image_path(imageDto.username, imageDto.month, imageDto.date)
    
    # 이미지 생성
    
    return image_path
    
def generate_image_path(username: str, month: str, date: str):
    image_path = make_uuid_with_prefix_and_suffix(f"./images/{username}-{month}-{date}", ".png")
    return image_path
