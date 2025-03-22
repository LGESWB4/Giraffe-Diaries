from typing import List
from dotenv import load_dotenv
import openai
import os

load_dotenv()

client = openai.OpenAI(api_key=os.getenv("GPT_API_KEY"))

def translate_and_generate_prompt(input_query, style_query, emotion_query):
    response = client.chat.completions.create(model="gpt-4",  # 모델은 "gpt-4"를 사용, "GPT-4o mini"는 지원되지 않음
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": f"Generate a list of important keywords for a detailed Stable Diffusion 2 prompt in English within 50 tokens, focusing on photography style, lightning, art medium. The keywords should be short and placed at the beginning, within 50 tokens. Use the following input:\n\nInput word: {input_query}\nStyle word: {style_query}\nEmotion word: {emotion_query}\n\nFormat: [keywords]"}
    ],
    max_tokens=70,  # 최대 토큰은 70으로 설정
    temperature=0.7)

    # 번역된 프롬프트 추출
    translated_prompt = response.choices[0].message.content.strip()

    return translated_prompt
