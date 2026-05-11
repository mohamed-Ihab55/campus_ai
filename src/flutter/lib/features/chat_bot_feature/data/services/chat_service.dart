import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatRemoteService {
  final Dio _dio;

  ChatRemoteService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['CHAT_BOT_API_KEY'] ?? '',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 300),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  Future<String> sendMessage({
    required String message,
    required String userId,
  }) async {
    final buffer = StringBuffer();

    final completer = Completer<void>();

    String? errorMsg;

    await sendMessageStreaming(
      message: message,
      userId: userId,
      onToken: (token) => buffer.write(token),
      onDone: () => completer.complete(),
      onError: (e) {
        errorMsg = e;
        completer.complete();
      },
    );

    await completer.future;

    if (errorMsg != null) {
      throw Exception(errorMsg);
    }

    final reply = buffer.toString().trim();

    if (reply.isEmpty) {
      throw Exception('Empty response from API');
    }

    return reply;
  }



  Future<void> sendMessageStreaming({
    required String message,
    required String userId,
    required void Function(String token) onToken,
    required void Function() onDone,
    required void Function(String error) onError,
    void Function(String messageId)? onMessageId,
  }) async {
    try {
      final response = await _dio.post(
        '/chat',
        data: {
          'question': message,
          'user_id': userId,
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );


      final responseBody = response.data;

      if (responseBody is! ResponseBody) {
        onError('Invalid response type');
        return;
      }

      final stream = responseBody.stream;

      await for (final chunk in stream) {
        final decoded = utf8.decode(chunk);

        final cleaned = decoded.replaceAll('\u200b', '');

        if (cleaned.isEmpty) continue;

        try {
          final data = jsonDecode(cleaned);

          if (data is Map<String, dynamic>) {
            if (data['message_id'] != null) {
              onMessageId?.call(data['message_id'].toString());
            }

            if (data['token'] != null) {
              onToken(data['token'].toString());
            }
          }
        } catch (_) {
          onToken(cleaned);
        }
      }

      onDone();
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          onError('Connection timeout');
          break;

        case DioExceptionType.receiveTimeout:
          onError('Response timeout');
          break;

        case DioExceptionType.connectionError:
          onError('No internet connection');
          break;

        default:
          onError('Request failed: ${e.message}');
      }
    } catch (e) {
      onError('Unexpected error: $e');
    }
  }


}
