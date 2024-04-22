import 'package:dartz/dartz.dart';
import 'package:socket_test/exceptions/api_exception.dart';
import 'package:socket_test/models/chat.dart';

abstract class ChatRepository {
  List<Chat> get chats;
  Stream<List<Chat>?> get chatStream;
  Future<void> sendMessage(String message, String groupChatId);
  Future<Either<ApiException, List<Chat>>> fetchChats();
  Future<void> fetchMessages(int chatId);
  Future<void> initSocket();
  Future<void> disconnectSocket();
  bool get isSocketConnected;
}
