import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_test/models/chat.dart';
import 'package:socket_test/models/message.dart';
import 'package:socket_test/repositories/chat/chat_repository_impl.dart';

final chatNotifierProvider = NotifierProvider<ChatListNotifier, List<Chat>>(() {
  return ChatListNotifier();
});

class ChatListNotifier extends Notifier<List<Chat>> {
  @override
  List<Chat> build() {
    return [];
  }

  Future<void> fetchChats() async {
    final result = await ref.read(chatRepositoryProvider).fetchChats();

    result.fold(
      (error) {
        // Handle error
      },
      (chats) {
        state = chats;
      },
    );
  }

  void receiveMessage(Message message) {
    final chat = state.firstWhere((chat) => chat.id == message.groupChatId);
    chat.messages.insert(0, message);
    state = [...state];
  }
}
