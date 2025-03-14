from typing import List

class ImageDto:
    username: str
    input_word: str
    style_word: str
    emotion_query: str
    month: str
    date: str
    style: str

    def __init__(self, username: str, input_word: str, style_word: str, emotion_query: str, month: str, date: str, style: str):
        self.username = username
        self.input_word = input_word
        self.style_word = style_word
        self.emotion_query = emotion_query
        self.month = month
        self.date = date
        self.style = style
