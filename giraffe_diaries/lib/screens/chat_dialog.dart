import 'package:flutter/material.dart';
import 'package:giraffe_diaries/contants/stream_config.dart';
import 'package:giraffe_diaries/services/stream_service.dart';
import '../styles/text_styles.dart';
import '../models/model_load.dart';
import 'package:get/get.dart';
import '../models/model_send.dart';
import 'package:llama_library/llama_library.dart';
import 'dart:async';

class ChatDialog extends StatefulWidget {
  final DateTime selectedDate;
  final String contenttext;
  final LlamaLibraryChatHistory chatHistory;
  final List<Map<String, String>> messages;
  const ChatDialog({
    super.key,
    required this.selectedDate,
    required this.contenttext,
    required this.chatHistory,
    required this.messages,
  });

  @override
  _ChatDialogState createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late LlamaLibraryChatHistory _chatHistory;
  late List<Map<String, String>> _messages;
  late LlamaLibrary _llamaLibrary;
  bool _isInitialized = false;
  bool _isLoading = false;
  String _currentResponse = '';
  Timer? _loadingTimer;
  String _loadingDots = '';
  bool _isFirstResponse = true;

  final StreamingService _streamingService = StreamingService();
  String _message = '';

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
    _chatHistory = widget.chatHistory;
    _messages = widget.messages;
    // 초기 인사 메시지
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_isInitialized) {
        _llamaLibrary = Get.find<LlamaLibrary>() ?? await modelLoad();
        _isInitialized = true;
      }
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _loadingTimer?.cancel();
    super.dispose();
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

  void _startLoadingAnimation() {
    _loadingTimer?.cancel();
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _loadingDots = _loadingDots.length >= 3 ? '' : _loadingDots + '.';
      });
    });
  }

  void _stopLoadingAnimation() {
    _loadingTimer?.cancel();
    setState(() {
      _loadingDots = '';
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() {
      widget.messages.add({
        'sender': 'user',
        'message': userMessage,
      });
      _isLoading = true;
      widget.messages.add({
        'sender': 'user',
        'message': _loadingDots,
      });
      _currentResponse = '';
      _startLoadingAnimation();
    });

    _scrollToBottom();

    try {
      String response = await chatmessage(
        userMessage,
        Get.find<LlamaLibrary>(),
        false,
        widget.chatHistory,
        (String modelres) {
          setState(() {
            widget.messages.last['message'] = widget.messages.last['message']! + modelres;
            _currentResponse = modelres;
            _stopLoadingAnimation();
          });
        },
      );
      setState(() {
        _isLoading = false;
        _currentResponse = '';
      });
    } catch (e) {
      setState(() {
        widget.messages.add({
          'sender': 'giraffe',
          'message': '죄송합니다. 오류가 발생했습니다.',
        });
        _isLoading = false;
        _currentResponse = '';
      });
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
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
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: widget.messages.length,
                  itemBuilder: (context, index) {
                    final message = widget.messages[index];
                    final isUser = message['sender'] == 'user';
                    final messageText = message['message'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isUser) ...[
                            CircleAvatar(
                              backgroundImage: AssetImage('assets/images/giraffe_logo.png'),
                              radius: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUser ? const Color(0xFFF6AD62) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                messageText,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isUser ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                          if (isUser) ...[
                            const SizedBox(width: 8),
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          ],
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
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 