from dto.ImageDto import ImageDto
from utils.uuid import make_uuid_with_prefix_and_suffix
def generate_image_path(imageDto: ImageDto):
    image_path = make_uuid_with_prefix_and_suffix(f"./images/{imageDto.username}-{imageDto.month}-{imageDto.date}", ".png")
    # 이미지 생성 코드
    return image_path
