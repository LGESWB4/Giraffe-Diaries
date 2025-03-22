# Giraffe-Diaries
네가 그린 그림 일기 (LGE SW Bootcamp - 최종 프로젝트)

네가 그린 그림 일기(Giraffe-Diaries)는 사용자가 그림을 그리면 해당 그림을 인식하여 일기를 작성할 수 있도록 도와주는 애플리케이션입니다.


## 주요 기능

- **일기 작성**: User가 매일매일의 일기 작성을 할 수 있습니다..
- **감정 분석**: on device AI로 사용자의 감정을 분석하여 맞춤형 이모지를 매칭합니다.
- **AI 채팅**:on device AI로 sLLM 모델과의 채팅을 할 수 있습니다.
- **그림 생성**: 감정 분석을 통한 감정, 키워드 추출기반으로 server AI(stable diffusion)를 통해 그림을 생성합니다. (원하는 그림의 화풍을 선택할 수 있습니다.) 
- **플랫폼 지원**: 현재 Android에서만 사용 가능합니다. (sLLM 모델 로드 관련 issue)
![표지](https://github.com/user-attachments/assets/4316a9a4-91b4-418a-a0a9-2cc42f736b22) ![INTRO](https://github.com/user-attachments/assets/24597c06-eb37-4ea7-b549-4f26e5515d89)
![APP](https://github.com/user-attachments/assets/bc0b4186-0b65-42a4-9ffc-989ad812b30e) ![MODEL](https://github.com/user-attachments/assets/52441f60-ef43-49fd-b3f5-9e6321eedb9e)



## 기술 스택

- **프론트엔드**: Flutter를 사용하여 크로스 플랫폼 모바일 애플리케이션을 개발하였습니다.
- **백엔드**: Python 기반의 서버로, 그림 인식 모델을 제공하고 클라이언트와 통신합니다.
- **모델 서버**:  Stable Difussion api 를 활용한 일기 기반 그림을 생성합니다.
- **모델**: on device sLLM 을 활용한 사용자의 일기 감정 분석 및 채팅 기능을 지원합니다.
- **sLLM 모델 로드**: General Developer의 llama_library_flutter를 활용하였습니다. https://pub.dev/documentation/llama_library_flutter/latest/ (Thank to GD.)

![다이어그램](https://github.com/user-attachments/assets/2afe357e-ac7e-42bf-a780-2bda031d01ad)

## 설치 및 실행 방법

1. 레포지토리를 클론합니다:
   ```bash
   git clone https://github.com/LGESWB4/Giraffe-Diaries.git
   ```

2. 프로젝트 디렉토리로 이동합니다:
   ```bash
   cd giraffe_diaries
   ```

3. 프론트엔드 설정:
   - Flutter 환경을 설정하고, 필요한 패키지를 설치합니다:
     ```bash
     flutter pub get
     ```
   - 애플리케이션을 실행합니다:
     ```bash
     flutter run
     ```

4. 백엔드 설정:
   - 필요한 Python 패키지를 설치합니다:
     ```bash
     pip install -r requirements.txt
     ```
   - 서버를 실행합니다:
     ```bash
     python server/app.py
     ```

## 사용 예시

1. 애플리케이션을 실행하고, 사용자는 원하는 날짜의 일기를 작성합니다.
2. 일기를 작성하고 나면, AI가 감정 분석과 키워드를 추출하여 저장합니다.
3. 추출된 감정에 매치된 이모지가 나타납니다.
4. 이미지 생성 버튼을 통해 원하는 화풍을 선택하고 일정 시간 이후 감정과 키워드 기반의 그림이 생성됩니다.
5. 그 날의 감정을 떠올리며 on Device sLLM AI모델과 대화해보세요!

<iframe width="560" height="315" src="https://youtube.com/shorts/R0ej2wA7h6Y" frameborder="0" allowfullscreen></iframe>
