from pydantic import BaseModel
from typing import List

class ImageRequest(BaseModel):
    username: str
    tokens: List[str]
    month: str
    date: str
