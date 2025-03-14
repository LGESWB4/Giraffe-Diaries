import subprocess

# **GGUF 모델 및 실행 파일 경로**
LLAMA_CLI_PATH = "/home/moons98.in/Giraffe-Diaries/llama.cpp/build/bin/llama-cli"
GGUF_MODEL_PATH = "/home/moons98.in/Giraffe-Diaries/model/ko-llm/weights/Llama-3.2-3B-Instruct/Llama-3.2-3B-Instruct-BF16.gguf"

def run_chat():
    """
    `llama-cli` 실행 후 사용자 입력을 받아 대화 진행.
    `/exit` 입력 시 종료.
    """
    print("📝 AI 챗봇을 시작합니다. 종료하려면 '/exit'을 입력하세요.")

    try:
        subprocess.run(
            [LLAMA_CLI_PATH, "-m", GGUF_MODEL_PATH, "-cnv","--interactive", "--simple-io"],
            check=True
        )
    except KeyboardInterrupt:
        print("\n👋 Chatbot shutting down.")

if __name__ == "__main__":
    run_chat()
