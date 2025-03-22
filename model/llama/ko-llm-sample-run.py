import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

# 모델 불러오기
model_name = "CarrotAI/Llama-3.2-Rabbit-Ko-3B-Instruct"
model = AutoModelForCausalLM.from_pretrained(model_name, torch_dtype=torch.float16, device_map="auto")
tokenizer = AutoTokenizer.from_pretrained(model_name)

# 패딩 토큰 설정 (없을 경우 오류 방지)
if tokenizer.pad_token is None:
    tokenizer.pad_token = tokenizer.eos_token if tokenizer.eos_token else tokenizer.unk_token

# 최대 컨텍스트 길이
MAX_TOKENS = 2048

# 초기 대화 프롬프트 (시스템 설정)
system_prompt = """<|begin_of_text|><|start_header_id|>system<|end_header_id|>

당신은 사용자의 일기를 읽고 감정을 공감하며 따뜻한 말투로 대화를 나누는 감성 챗봇입니다.
항상 **존댓말**을 사용하며, 사용자의 감정을 존중하는 **친절하고 부드러운 대화**를 나누세요.
너무 길지 않지만, **정서적인 교감을 유지하며 자연스럽게 이야기하세요**.

1️⃣ **공감 우선**: 사용자가 힘들면 "정말 힘들었겠어요.", 기쁘면 "정말 좋은 하루였네요!" 등 **감정에 맞는 반응**을 하세요.
2️⃣ **자연스러운 질문**: 사용자가 더 이야기하고 싶게 **부드러운 질문**을 던지세요.
3️⃣ **부담 없는 대화**: 분석적이거나 딱딱한 말투 대신, **친구처럼 다정한 말투**를 사용하세요.

<|eot_id|>
"""

# 초기 대화 기록 (리스트로 관리)
conversation_history = [system_prompt]

def trim_conversation():
    """최대 토큰 길이를 초과하면 앞부분을 삭제하여 맥락 유지"""
    while True:
        encoded = tokenizer("".join(conversation_history), return_tensors="pt")
        if encoded.input_ids.shape[1] <= MAX_TOKENS:
            break  # 토큰 길이가 초과하지 않으면 종료
        conversation_history.pop(1)  # 시스템 프롬프트는 유지한 채 가장 오래된 메시지 삭제

# 사용자 입력을 기반으로 대화 진행
while True:
    try:
        user_input = input("🧑‍💻 사용자: ").strip()

        # 종료 조건
        if user_input.lower() in ["exit", "quit", "종료"]:
            print("🛑 대화를 종료합니다.")
            break

        # 대화 기록 업데이트
        conversation_history.append(f"<|start_header_id|>user<|end_header_id|>\n\n{user_input}<|eot_id|>\n")
        conversation_history.append("<|start_header_id|>assistant<|end_header_id|>\n")  # 어시스턴트 응답 시작

        # 대화 기록 길이 조절
        trim_conversation()

        # 입력 변환 (토크나이저 적용)
        inputs = tokenizer("".join(conversation_history), return_tensors="pt", padding=True, truncation=True)
        inputs = {key: value.to(model.device) for key, value in inputs.items()}  # GPU 이동

        # 모델 예측
        with torch.no_grad():
            output_ids = model.generate(
                **inputs,
                max_length=inputs["input_ids"].shape[1] + 256,  # 현재 입력 길이 + 예상 응답 길이
                do_sample=True,  # 확률적 샘플링 활성화 (보다 자연스러운 응답)
                temperature=0.7,  # 창의성 조절
                top_p=0.9,  # 상위 p% 확률의 토큰만 고려
                pad_token_id=tokenizer.pad_token_id,
                eos_token_id=tokenizer.eos_token_id
            )

        # 응답 디코딩
        response = tokenizer.decode(output_ids[0], skip_special_tokens=True)

        # 어시스턴트 응답 추출
        assistant_response = response.split("<|start_header_id|>assistant<|end_header_id|>")[-1].strip()
        assistant_response = assistant_response.split("<|eot_id|>")[0].strip()  # 끝 태그 제거

        # 응답 출력
        print(f"🤖 어시스턴트: {assistant_response}")

        # 대화 기록 업데이트
        conversation_history.append(f"{assistant_response}<|eot_id|>\n")

    except Exception as e:
        print(f"⚠️ 오류 발생: {e}")
