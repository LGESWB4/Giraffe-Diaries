from pydantic import BaseModel
from typing import List

class ImageRequest(BaseModel):
    username: str
    input_word: str
    style_word: str
    emotion_query: str
    month: str
    date: str
