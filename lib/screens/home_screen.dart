import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_test/repositories/auth/auth_repository_impl.dart';
import 'package:socket_test/repositories/chat/chat_list_notifier.dart';
import 'package:socket_test/repositories/chat/chat_repository_impl.dart';
import 'package:socket_test/router/app_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    if (!ref.read(chatRepositoryProvider).isSocketConnected) {
      ref.read(chatRepositoryProvider).initSocket();
    }

    ref.read(chatNotifierProvider.notifier).fetchChats();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!ref.read(chatRepositoryProvider).isSocketConnected) {
          ref.read(chatRepositoryProvider).initSocket();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        ref.read(chatRepositoryProvider).disconnectSocket();
        break;
      default:
        break;
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatNotifierProvider);

    debugPrint('ChatRepository: $chats');
    debugPrint('is connected?: ${ref.read(chatRepositoryProvider).isSocketConnected}');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Chats'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(chatRepositoryProvider).initSocket();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              ref.read(chatRepositoryProvider).disconnectSocket();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];

          return ListTile(
            onTap: () {
              context.goNamed(
                AppRoutes.chat.name,
                pathParameters: {'chatId': chat.id.toString()},
              );
            },
            title: Text(chat.name),
            subtitle: Text(chat.createdAt.toString()),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(authRepositoryProvider(null)).signOut();
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
