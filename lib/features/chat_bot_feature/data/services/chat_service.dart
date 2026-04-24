import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campus_ai/features/chat_bot_feature/data/model/chat_model.dart';

class ChatRemoteService {
  final Dio _dio;

  ChatRemoteService()
      : _dio = Dio(
          BaseOptions(
            // baseUrl: dotenv.env['CHAT_BOT_API_KEY'] ?? '',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> conversationHistory,
  }) async {
    final response = await _dio.post(
      '/chat',
      data: {
        'message': message,
        'history': conversationHistory
            .map((m) => {
                  'role': m.role.name,
                  'content': m.content,
                })
            .toList(),
      },
    );

    final reply = response.data['reply'];
    if (reply == null || reply is! String) {
      throw Exception('Unexpected response format from API');
    }

    return reply;
  }
}