import 'package:diary/mood_buddy/services/gemini_service.dart';
import 'package:diary/mood_buddy/widgets/chat_input.dart';
import 'package:diary/mood_buddy/widgets/chat_message.dart';
import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class MoodBuddyPage extends StatefulWidget {
  const MoodBuddyPage({super.key});

  @override
  State<MoodBuddyPage> createState() => _MoodBuddyPageState();
}

class _MoodBuddyPageState extends State<MoodBuddyPage>
    with SingleTickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final GeminiService _geminiService = GeminiService();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late final AnimationController _loadingController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    _loadingController.repeat(reverse: true);

    _addInitialMessage();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addInitialMessage() {
    _messages.add(
      const ChatMessage(
        text: "Hi! I'm your Mood Buddy. How are you feeling today?",
        isUser: false,
        animate: false,
      ),
    );
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await _geminiService.getResponse(text);

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          animate: true,
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add(const ChatMessage(
          text: "Sorry, I couldn't process that. Please try again.",
          isUser: false,
          isError: true,
        ));
      });
      _scrollToBottom();
    }
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Lottie.asset(
                AppMedia.moodbubby,
                fit: BoxFit.cover,
                repeat: true,
                animate: true,
                reverse: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Generating...',
              style: GoogleFonts.poppins(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Mood Buddy',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                reverse: false,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemBuilder: (context, index) => _messages[index],
              ),
            ),
          ),
          if (_isTyping) _buildLoadingIndicator(),
          ChatInput(
            onSubmitted: _handleSubmitted,
          ),
        ],
      ),
    );
  }
}
