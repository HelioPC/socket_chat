import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_test/repositories/chat/chat_list_notifier.dart';
import 'package:socket_test/repositories/chat/chat_repository_impl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId});

  final int chatId;

  @override
  ConsumerState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {

  @override
  Widget build(BuildContext context) {
    final chatList = ref.watch(chatNotifierProvider);

    final chat = chatList.firstWhere((chat) => chat.id == widget.chatId);

    debugPrint('Messages length: ${chat.messages.length}');

    return Scaffold(
      appBar: AppBar(
        title: Text(chat.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(chatRepositoryProvider).fetchMessages(chat.id);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  chat.description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final message = chat.messages[index];
                return ListTile(
                  title: Text(message.content),
                  subtitle: Text(message.createdAt.toString()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
