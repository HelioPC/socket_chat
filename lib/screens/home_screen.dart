import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_test/repositories/auth/auth_repository_impl.dart';
import 'package:socket_test/repositories/chat/chat_repository_impl.dart';

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

    if (!ref.read(chatProvider).isSocketConnected) {
      ref.read(chatProvider).initSocket();
    }

    ref.read(chatProvider).fetchChats();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!ref.read(chatProvider).isSocketConnected) {
          ref.read(chatProvider).initSocket();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        ref.read(chatProvider).disconnectSocket();
        break;
      default:
        break;
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final chatRepository = ref.watch(chatProvider);

    debugPrint('ChatRepository: ${chatRepository.chats}');
    debugPrint('is connected?: ${ref.read(chatProvider).isSocketConnected}');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Chats'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(chatProvider).initSocket();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              ref.read(chatProvider).disconnectSocket();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: StreamBuilder(
          stream: ref.read(chatProvider).chatStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final chats = snapshot.data;

              if (chats == null) {
                return const Center(
                  child: Text('No chats found!'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];

                  return ListTile(
                    title: Text(chat.name),
                    subtitle: Text(chat.createdAt.toString()),
                  );
                },
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(authRepositoryProvider(null)).signOut();
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
