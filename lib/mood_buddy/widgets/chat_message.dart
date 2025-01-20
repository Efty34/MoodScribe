import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isError;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.blue[600]
                    : isError
                        ? Colors.red[50]
                        : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 20),
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
                text,
                style: GoogleFonts.poppins(
                  color: isUser
                      ? Colors.white
                      : isError
                          ? Colors.red[800]
                          : Colors.grey[800],
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (isUser) _buildUserAvatar(),
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
      child: Center(
        child: Icon(
          Icons.psychology_rounded,
          color: Colors.blue[800],
          size: 24,
        ),
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