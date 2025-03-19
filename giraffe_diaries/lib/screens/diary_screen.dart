import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../styles/text_styles.dart';
import 'chat_dialog.dart';
import '../models/model_load.dart';
import 'package:llama_library/llama_library.dart';
import '../models/model_send.dart';

class DiaryScreen extends StatefulWidget {
  final List<String> hashtags = ['멋짐', '자신감'];
  final String emojiImage = 'assets/emoji_images/cool_emoji.jpg';
  
  final String generatedImageUrl;
  final DateTime selectedDate;
  final String contenttext;
  final String encodetext;
  final LlamaLibrary llamaLibrary;
  
  DiaryScreen({
    super.key,
    required this.generatedImageUrl,
    required this.selectedDate,
    required this.contenttext,
    required this.encodetext,
    required this.llamaLibrary,
  });

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final LlamaLibraryChatHistory _chatHistory = LlamaLibraryChatHistory();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 초기 인사 메시지
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      
      _chatHistory.clear();
      
      String response = '';
      response = await chatmessage(widget.contenttext, widget.llamaLibrary, false, _chatHistory, (String modelres) {
        debugPrint("modelres: $modelres");
      });
      _messages.add({
        'sender': 'giraffe',
        'message': response,
      });
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    widget.llamaLibrary.dispose();
    super.dispose();
  }

  void _showImageDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.save_alt, color: Colors.black),
                      onPressed: () {
                        // TODO: 이미지 저장 기능 구현
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    widget.generatedImageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.black),
            onPressed: () {
              // TODO: 저장 기능 구현
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // TODO: 메뉴 기능 구현
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이모지와 날짜
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        widget.emojiImage,
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.selectedDate.year}년 ${widget.selectedDate.month}월 ${widget.selectedDate.day}일',
                        style: AppTextStyles.heading1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // 해시태그
                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: widget.hashtags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#$tag',
                        style: AppTextStyles.bodyLarge,
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                
                // 생성된 이미지
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: GestureDetector(
                      onTap: () => _showImageDetail(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: widget.generatedImageUrl.isEmpty
                          ? Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '이미지가 없습니다',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Image.network(
                              widget.generatedImageUrl,
                              fit: BoxFit.contain,
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // 일기 내용
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      widget.contenttext,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          
          // 기린과 대화하기 버튼
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      isDismissible: true,
                      enableDrag: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: ChatDialog(
                          selectedDate: widget.selectedDate,
                          contenttext: widget.contenttext,
                          llamaLibrary: widget.llamaLibrary,
                          chatHistory: _chatHistory,
                          messages: _messages,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading ? Color(0xFFE5E5E5) : const Color(0xFFF6AD62),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    _isLoading ? '기린이 준비중...' : '기린과 대화할래?',
                    style: AppTextStyles.buttonText.copyWith(
                      color: _isLoading ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 