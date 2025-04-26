import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  // Base context for the AI to understand its role
  static const String _baseContext = '''
You are MoodBuddy, a supportive AI assistant focused on helping users manage stress, 
improve mental well-being, and maintain productive daily routines. Your responses should be:
1. Supportive and empathetic
2. Professional and evidence-based
3. Focused on mental health, stress management, and productivity
4. Safe and appropriate for all ages
5. Never harmful or encouraging negative behaviors

You can help with:
- Stress management techniques
- Mood improvement suggestions
- Productivity and task management tips
- Healthy lifestyle recommendations
- General mental well-being advice

You cannot and will not:
- Provide medical diagnoses or replace professional medical advice
- Generate harmful, inappropriate, or adult content
- Encourage dangerous or unhealthy behaviors
- Share personal or private information
- Provide financial or legal advice
''';

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is missing in environment variables!');
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  Future<String> getResponse(String userPrompt) async {
    try {
      // Clean and validate the user prompt
      final sanitizedPrompt = _sanitizePrompt(userPrompt);
      if (sanitizedPrompt == null) {
        return 'I’m sorry, but I am unable to provide that information. However, I would be happy to assist you with something else. Let me know how I can help!';
      }

      // Combine base context with user prompt
      final fullPrompt = '''
$_baseContext

User Query: $sanitizedPrompt

Remember to keep the response:
- Supportive and constructive
- Focused on mental well-being
- Safe and appropriate
- Professional and helpful

Response:
''';

      final content = [Content.text(fullPrompt)];
      final response = await _model.generateContent(content);
      return response.text ??
          'I apologize, but I cannot generate a response at this moment. Please try again.';
    } catch (e) {
      throw Exception('Failed to get response: $e');
    }
  }

  String? _sanitizePrompt(String prompt) {
    // Convert to lowercase for easier checking
    final lowerPrompt = prompt.toLowerCase();

    // List of forbidden topics or red flags
    final forbiddenTopics = [
      'porn',
      'xxx',
      'sex',
      'nude',
      'dating',
      'gambling',
      'drugs',
      'alcohol',
      'suicide',
      'self-harm',
      'kill',
      'hack',
      'crack',
      'steal',
      'illegal',
      'weapon',
      'violence',
    ];

    // Check for forbidden topics
    for (final topic in forbiddenTopics) {
      if (lowerPrompt.contains(topic)) {
        return null;
      }
    }

    // List of required contexts (at least one should be relevant)
    final validContexts = [
      'stress',
      'anxiety',
      'mood',
      'feel',
      'task',
      'todo',
      'work',
      'study',
      'relax',
      'calm',
      'peace',
      'habit',
      'routine',
      'schedule',
      'help',
      'advice',
      'tip',
      'mental',
      'health',
      'well',
      'sleep',
      'rest',
      'tired',
      'focus',
      'concentrate',
      'productivity',
      'organize',
      'plan',
      'manage',
    ];

    // Check if the prompt is relevant to the app's purpose
    bool isRelevant =
        validContexts.any((context) => lowerPrompt.contains(context));
    if (!isRelevant && prompt.length > 20) {
      // If longer prompt doesn't contain any valid context, it might be off-topic
      return null;
    }

    return prompt;
  }
}
