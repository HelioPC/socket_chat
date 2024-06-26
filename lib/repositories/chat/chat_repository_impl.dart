import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_test/constants/storage_keys.dart';
import 'package:socket_test/constants/urls.dart';
import 'package:socket_test/exceptions/api_exception.dart';
import 'package:socket_test/models/chat.dart';
import 'package:socket_test/models/message.dart';
import 'package:socket_test/repositories/auth/auth_repository.dart';
import 'package:socket_test/repositories/auth/auth_repository_impl.dart';
import 'package:socket_test/repositories/chat/chat_list_notifier.dart';
import 'package:socket_test/repositories/chat/chat_repository.dart';
import 'package:socket_test/utils/rest_client.dart';
import 'package:socket_test/utils/storage.dart';

final chatRepositoryProvider = Provider.autoDispose<ChatRepository>(
  (ref) => ChatRepositoryImpl(
    ref: ref,
    restClient: ref.read(restClientProvider(null)),
    storage: ref.read(storageProvider),
    authRepository: ref.read(authRepositoryProvider(null)),
  ),
);

class ChatRepositoryImpl implements ChatRepository {
  final ProviderRef ref;
  final RestClient restClient;
  final Storage storage;
  final AuthRepository authRepository;

  io.Socket? _messageSocket;
  final List<Chat> _chats = [];
  final StreamController<List<Chat>?> _chatStream = StreamController();

  ChatRepositoryImpl({
    required this.ref,
    required this.restClient,
    required this.storage,
    required this.authRepository,
  });

  bool get _isAuthenticated => authRepository.user != null;

  @override
  Stream<List<Chat>?> get chatStream => _chatStream.stream;

  @override
  List<Chat> get chats => _chats;

  @override
  bool get isSocketConnected => _messageSocket?.connected ?? false;

  @override
  Future<void> initSocket() async {
    if (!_isAuthenticated) {
      debugPrint('User not authenticated');
      return;
    }

    debugPrint('Init socket...');

    final token = await storage.read(StorageKeys.accessToken);
    final headers = {'Authorization': 'Bearer $token'};

    _messageSocket = io.io(
      'ws://localhost:3000/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders(headers)
          .build(),
    );

    _messageSocket?.onDisconnect((_) => debugPrint('Disconnected'));

    _messageSocket
        ?.onConnectError((data) => debugPrint('Connect error: $data'));

    _messageSocket?.onError((data) => debugPrint('Error: $data'));

    _messageSocket?.on('message', (data) {
      try {
        debugPrint('Message: $data');

        final message = Message.fromMap(data);

        ref.read(chatNotifierProvider.notifier).receiveMessage(message);

        _chatStream.add(_chats);
      } catch (e) {
        debugPrint('Error: $e');
      }
    });
  }

  @override
  Future<void> disconnectSocket() async {
    _messageSocket?.disconnect();
    _messageSocket?.dispose();
  }

  @override
  Future<void> sendMessage(String message, String groupChatId) async {
    if (!_isAuthenticated) {
      debugPrint('User not authenticated');
      return;
    }

    final userId = authRepository.user?.id ?? -1;

    if (userId == -1) {
      debugPrint('User not found');
      return;
    }

    final messageModel = {
      'content': message,
      'senderId': userId,
      'conversationId': groupChatId,
    };

    _messageSocket?.emit('message', messageModel);
  }

  @override
  Future<Either<ApiException, List<Chat>>> fetchChats() async {
    if (!_isAuthenticated) {
      debugPrint('User not authenticated');
      return Left(ApiException(code: 401));
    }

    try {
      final response =
          await restClient.auth.getRequest(path: UrlsConstants.fetchChatsUrl);

      switch (response.statusCode) {
        case 400:
          return Left(ApiException(code: 400));
        case 401:
          return Left(ApiException(code: 401));
        case 403:
          return Left(ApiException(code: 403));
        case 200:
          try {
            final chats = (json.decode(response.body) as List)
                .map((e) => Chat.fromMap(e))
                .toList();

            _chats.clear();
            _chats.addAll(chats);
            _chatStream.add(_chats);

            fetchAllChatsMessages();

            return Right(chats);
          } catch (e) {
            debugPrint('Error: $e');
            return Left(ApiException(code: 999, message: e.toString()));
          }
        default:
          return Left(ApiException(code: response.statusCode));
      }
    } on ApiException catch (e) {
      return Left(e);
    }
  }

  Future<void> fetchAllChatsMessages() async {
    if (!_isAuthenticated) {
      debugPrint('User not authenticated');
      return;
    }

    for (final chat in _chats) {
      await fetchMessages(chat.id);
    }
  }

  @override
  Future<void> fetchMessages(int chatId) async {
    if (!_isAuthenticated) {
      debugPrint('User not authenticated');
      return;
    }

    const limit = 10;
    final offset =
        _chats.firstWhere((element) => element.id == chatId).messages.length;

    try {
      final response = await restClient.auth.getRequest(
        path:
            '${UrlsConstants.fetchMessagesUrl}$chatId/messages?limit=$limit&offset=$offset',
      );

      debugPrint('Response: ${response.body}');

      switch (response.statusCode) {
        case 400:
        case 401:
        case 403:
          return;
        case 200:
          try {
            final messages = (json.decode(response.body) as List)
                .map((e) => Message.fromMap(e))
                .toList();

            final chat = _chats.firstWhere((element) => element.id == chatId);
            chat.messages.clear();
            chat.messages.addAll(messages);

            _chatStream.add(_chats);
          } catch (e) {
            debugPrint('Error: $e');
          }
          break;
        default:
          break;
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
