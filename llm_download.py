from huggingface_hub import hf_hub_download


repo_id = "mradermacher/Llama-3-Mopeyfied-Psychology-v2-i1-GGUF"
filename = "Llama-3-Mopeyfied-Psychology-v2.i1-Q4_K_S.gguf"

save_dir = "/home/moons98.in/Giraffe-Diaries/model/ko-llm/weights"
file_path = hf_hub_download(repo_id=repo_id, filename=filename, local_dir=save_dir)

print(f"Downloaded file path: {file_path}")