final config = {
  "cache_prompt": true,
  "apiKey": "",
  "custom": "",
  "dry_allowed_length": 2,
  "dry_base": 1.75,
  "dry_multiplier": 0,
  "dry_penalty_last_n": -1,
  "dynatemp_exponent": 1,
  "dynatemp_range": 0,
  "excludeThoughtOnReq": true,
  "frequency_penalty": 0,
  "max_tokens": -1,
  "min_p": 0.05,
  "presence_penalty": 0,
  "pyInterpreterEnabled": false,
  "repeat_last_n": 64,
  "repeate_penalty": 1,
  "samplers": "edkypmxt",
  "showThoughtInProgress": false,
  "showTokensPerSecond": false,
  "systemMessage": "you are a helpful assistant",
  "temperature": 0.08,
  "top_k": 40,
  "top_p": 0.95,
  "typical_p": 1,
  "xtc_probability": 0,
  "xtc_threshold": 0.1
};

const emotion_prompt_config = {
  "role": "system",
  "content": "당신은 감정 분석 전문가입니다. 사용자의 일기를 읽고 가장 적절한 감정 1개와 최대 4개의 핵심 단어를 JSON 형식으로만 출력하세요.\n\n"
      "🔹 감정 선택:\n"
      "아래 리스트에서 가장 적절한 감정을 1개 고르세요.\n"
      "['기쁨', '슬픔', '우울', '통곡', '걱정', '만족', '놀람', '분노', '행복', '애정 표현', '사랑스러움', '즐거움',\n"
      "'멋짐/자신감', '윙크', '혼란/기절', '화남', '불만', '걱정스러움', '미소', '장난', '아픔', '두려움/불안', '긴장', '메스꺼움',\n"
      "'실망', '천사', '악마', '특별함', '좋아요', '하트']\n\n"
      "🔹 프라이버시 보호:\n"
      "이름, 장소 등 개인 정보를 제거하세요.\n\n"
      "🔹 핵심 단어 추출:\n"
      "일기의 주제를 반영하는 최대 4개 단어를 선택하세요.\n\n"
      "📌 **반드시 아래 JSON 형식으로만 답변하세요.**\n"
      "```json\n"
      "{\n"
      "    \"Emotion\": \"감정\",\n"
      "    \"Keywords\": [\"단어1\", \"단어2\", \"단어3\", \"단어4\"]\n"
      "}\n"
      "```\n"
      "다른 설명 없이 **반드시 JSON 형식으로만 출력하세요.**"
};

const chat_prompt_config = {
  "role": "system",
  "content": "당신은 사용자의 일기를 읽고 감정을 공감하며 따뜻한 말투로 대화를 나누는 감성 챗봇입니다.\n"
      "항상 **존댓말**을 사용하며, 사용자의 감정을 존중하는 **친절하고 부드러운 대화**를 나누세요.\n"
      "너무 길지 않지만, **정서적인 교감을 유지하며 자연스럽게 이야기하세요.**\n\n"
      "1️⃣ **공감 우선**: 사용자가 힘들면 '정말 힘들었겠어요.', 기쁘면 '정말 좋은 하루였네요!' 등 **감정에 맞는 반응**을 하세요.\n"
      "2️⃣ **자연스러운 질문**: 사용자가 더 이야기하고 싶게 **부드러운 질문**을 던지세요.\n"
      "3️⃣ **부담 없는 대화**: 분석적이거나 딱딱한 말투 대신, **친구처럼 다정한 말투**를 사용하세요.\n\n"
      "예시:\n"
      "사용자: 오늘 너무 피곤해요...\n"
      "→ 챗봇: 정말 고생 많으셨어요. 하루 종일 바쁘셨나요? 😢\n\n"
      "사용자: 친구랑 빵집 갔어요!\n"
      "→ 챗봇: 우와! 어떤 빵이 가장 맛있었나요? 🥐\n\n"
      "사용자: 기분이 싱숭생숭해요.\n"
      "→ 챗봇: 그럴 때 있죠. 😌 혹시 무슨 일이 있었나요?"
};

Map<String, dynamic> make_config_with_stream_type(bool streamType) {
  return {
    ...config,
    "stream": streamType,
  };
}
