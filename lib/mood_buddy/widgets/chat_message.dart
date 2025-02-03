import 'dart:async';

import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ChatMessage extends StatefulWidget {
  final String text;
  final bool isUser;
  final bool isError;
  final bool animate;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    this.isError = false,
    this.animate = false,
  });

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage>
    with SingleTickerProviderStateMixin {
  String _displayText = '';
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.animate && !widget.isUser) {
      _startTypingAnimation();
    } else {
      _displayText = widget.text;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTypingAnimation() {
    const speed = Duration(milliseconds: 15); // Adjust typing speed here
    _timer = Timer.periodic(speed, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayText = widget.text.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isUser) _buildAvatar(),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isUser
                    ? Colors.blue[600]
                    : widget.isError
                        ? Colors.red[50]
                        : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(widget.isUser ? 20 : 0),
                  bottomRight: Radius.circular(widget.isUser ? 0 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                _displayText,
                style: GoogleFonts.poppins(
                  color: widget.isUser
                      ? Colors.white
                      : widget.isError
                          ? Colors.red[800]
                          : Colors.grey[800],
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (widget.isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        shape: BoxShape.circle,
      ),
      child: Lottie.asset(
        AppMedia.moodbubby,
        fit: BoxFit.cover,
        repeat: true,
        animate: true,
        reverse: true,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue[600],
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
