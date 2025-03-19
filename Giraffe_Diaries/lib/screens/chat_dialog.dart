import 'package:flutter/material.dart';
import 'package:giraffe_diaries/contants/stream_config.dart';
import 'package:giraffe_diaries/services/stream_service.dart';
import '../styles/text_styles.dart';

class ChatDialog extends StatefulWidget {
  final DateTime selectedDate;

  const ChatDialog({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _ChatDialogState createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  final StreamingService _streamingService = StreamingService();
  String _message = '';
  bool _isLoading = false;

  void _startStreaming() {
    const url = 'http://35.206.251.58:8081/v1/chat/completions';
    var body = {
      ...make_config_with_stream_type(true),
      'messages': [
        chat_prompt_config,
        ..._messages,
      ],
    };

    setState(() {
      _isLoading = true;
      // 스트리밍 시작할 때 새로운 메시지 추가
      _messages.add({
        'role': 'assistant',
        'content': '',
      });
    });

    _streamingService.streamPostRequest(url, body).listen(
      (content) {
        setState(() {
          _message += content;
          // 마지막 메시지(기린의 응답) 업데이트
          _messages.last['content'] = _message;
          print("content: $_message");
        });
        _scrollToBottom();
      },
      onError: (error) {
        print('Error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
        setState(() => _isLoading = false);
      },
      onDone: () {
        setState(() {
          _message = '';
          _isLoading = false;
        });
        _scrollToBottom();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // 초기 인사 메시지
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': '안녕하세요! 저는 당신의 이야기를 듣고 싶은 기린AI에요. 오늘 하루는 어떠셨나요?',
        });
      });
    });
  }

  void _sendMessage(String text) {
    print("text: $text");
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'content': text,
      });
      // 기린의 응답 (예시)

      _message = '';
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();
    _startStreaming();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFFFFEDDA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.selectedDate.year}년 ${widget.selectedDate.month}월 ${widget.selectedDate.day}일',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFEA580C),
                                width: 1,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Image.asset(
                                'assets/images/giraffe_logo.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          message['content']!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '기린과 대화하세요!',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6AD62),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _sendMessage(_messageController.text),
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
