import os
from utils import ensure_dir
from huggingface_hub import hf_hub_download


def ensure_dir(path):
    d = os.path.dirname(path)
    if not os.path.exists(d):
        os.makedirs(d)

        
repo_id = [
    "MaziyarPanahi/Llama-3.2-3B-Instruct-GGUF",
    "joongi007/ktdsbaseLM-v0.13-onbased-llama3.1-GGUF",
    "mradermacher/recoilme-gemma-2-9B-v0.4-i1-GGUF"
]

filename = [
    "Llama-3.2-3B-Instruct.fp16.gguf",
    "ktdsbaseLM-v0.13-onbased-llama3.1-Q4_K_M.gguf",    
    "recoilme-gemma-2-9B-v0.4.i1-Q4_K_M.gguf"
]


for repo, n_file in zip(repo_id, filename):
    save_dir = "/home/moons98.in/Giraffe-Diaries/model/ko-llm/weights"
    file_path = hf_hub_download(repo_id=repo_id, filename=filename, local_dir=save_dir)

    print(f"Downloaded file path: {file_path}")


'''
### llama 실행 커맨드

cd /home/moons98.in/Giraffe-Diaries/llama.cpp

# gguf 변환
# python llama.cpp/convert-hf-to-gguf.py {스냅샷 저장한 폴더 위치} --outfile {내보낼 gguf 모델 위치}.gguf
python ./convert-hf-to-gguf.py /home/moons98.in/Giraffe-Diaries/model/ko-llm/weights/Llama-3.2-3B-Instruct --outfile /home/moons98.in/Giraffe-Diaries/model/ko-llm/weights/Llama-3.2-3B-Instruct.gguf

# remove cache
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
pkill -9 llama-cli

# gguf 모델 실행
./llama-cli --threads 6 -n 512 -cnv -m <model_path>
./llama-server --mlock -n 512 -t 6 --port 8080 --host 0.0.0.0 -m <model_path>
'''
