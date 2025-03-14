from typing import List

class ImageDto:
    username: str
    tokens: List[str]
    month: str
    date: str
    style: str

    def __init__(self, username: str, tokens: List[str], month: str, date: str, style: str):
        self.username = username
        self.tokens = tokens
        self.month = month
        self.date = date
        self.style = style
