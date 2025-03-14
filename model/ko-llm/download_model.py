import os
from utils import ensure_dir
from huggingface_hub import snapshot_download


MODEL_ID = "bartowski/Llama-3.2-3B-Instruct-GGUF"
MODEL_NAME = MODEL_ID.split('/')[-1]  # "Llama-3.2-3B-Instruct"

SAVE_PATH = os.path.join('/home/moons98.in/Giraffe-Diaries/model/ko-llm/weights', MODEL_NAME)

snapshot_download(
    repo_id=MODEL_ID, 
    local_dir=SAVE_PATH,
    local_dir_use_symlinks=False, 
    revision="main"
)

print(f"Save Path : {SAVE_PATH}")


# llama.cpp 

'''
cd /home/moons98.in/Giraffe-Diaries/llama.cpp

# gguf 변환
# python llama.cpp/convert-hf-to-gguf.py {스냅샷 저장한 폴더 위치} --outfile {내보낼 gguf 모델 위치}.gguf
python ./convert-hf-to-gguf.py /home/moons98.in/Giraffe-Diaries/model/ko-llm/weights/Llama-3.2-3B-Instruct --outfile /home/moons98.in/Giraffe-Diaries/model/ko-llm/weights/Llama-3.2-3B-Instruct.gguf

# gguf quantization ??



# gguf 모델 실행
./build/bin/llama-cli --threads 4 -n 512 -cnv -sys "You are a helpful assistant" -m <model_path>
./build/bin/llama-cli --threads 4 -n 512 --top-p 0.9 --top-k 50 --repeat-penalty 1.5 -cnv -sys "너는 친절하고 공감이 뛰어난 친구야. 사용자와 따뜻한 대화를 나누고, 항상 응원하며 지원해줘." -m /home/moons98.in/Giraffe-Diaries/model/ko-llm/weights/ktdsbaseLM/ktdsbaseLM-v0.14-Onbased-Llama3.1-8.0B-BF16.gguf

오늘 날씨 참 좋다!


# benchmark
./llama-bench -m /home/moons98.in/Giraffe-Diaries/model/ko-llm/weights/Llama-3.2-3B-Instruct/Llama-3.2-3B-Instruct-BF16.gguf

'''
