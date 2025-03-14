import os
import gc
import time
import psutil
import constant

import torch
from diffusers import DiffusionPipeline

from openai import OpenAI
client = OpenAI(api_key=constant.openai_key)

# server setting
'''
# nvidia-driver (driver=530, cuda=12.x)
- https://cloud.google.com/compute/docs/gpus/install-drivers-gpu?hl=ko#linux-startup-script

# conda python=3.10, torch==2.4.1
conda create -n giraffe-model python=3.10
conda install pytorch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 pytorch-cuda=12.4 -c pytorch -c nvidia
pip install -r requirements.txt

# conda init
source /home/bmtosss/anaconda3/bin/activate
conda activate giraffe-model

'''

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


### 
# make prompt
input_word = "등산, 단풍"
style_word = "유화"
emotion_query = "보람차다"

start_time = time.time()
prompt = translate_and_generate_prompt(input_word, style_word, emotion_query)
end_time = time.time()
execution_time = end_time - start_time

print("[OpenAI-API]")
print(f"Execution_time : {execution_time}")
print("Generated Stable Diffusion Prompt:")
print(f"{prompt}\n")

# inference
image_path = "./inference_output.png"
device = "cuda" if torch.cuda.is_available() else "cpu"

gc.collect()
torch.cuda.empty_cache()

pipe = DiffusionPipeline.from_pretrained("stabilityai/stable-diffusion-xl-base-1.0", torch_dtype=torch.float16, use_safetensors=True, variant="fp16")
pipe.to(device)

start_time = time.time()

images = pipe(prompt=prompt).images[0]
images.save(image_path)

end_time = time.time()
execution_time = end_time - start_time

process = psutil.Process()
memory_usage = process.memory_info().rss / (1024 * 1024)  # Convert to MB

print("[SDXL-base]")
print(f"Inference device : {device}")
print(f"Execution_time : {execution_time}")
print(f"Memory_usage : {memory_usage}")
print(f"Image_path : {image_path}")
