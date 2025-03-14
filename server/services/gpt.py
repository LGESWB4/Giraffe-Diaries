from typing import List
from dotenv import load_dotenv
import openai
import os

load_dotenv()

client = openai.OpenAI(api_key=os.getenv("GPT_API_KEY"))

def translate_to_english(words: List[str]):
    response = client.responses.create(
        model="gpt-4o-mini",
        input="please translate each words to english and return only the words with space:" + " ".join(words)
    )
    return response.output_text.split()
