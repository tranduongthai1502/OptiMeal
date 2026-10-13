import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';

final chatRepositoryProvider = Provider<ChatRepositoryImpl>((ref) {
  return ChatRepositoryImpl();
});

final chatMessagesStreamProvider = StreamProvider.family
    .autoDispose<List<ChatMessage>, String>((ref, reservationId) {
  return ref.watch(chatRepositoryProvider).getMessagesStream(reservationId);
});

class ChatScreen extends ConsumerStatefulWidget {
  final String reservationId;

  const ChatScreen({super.key, required this.reservationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(authStateProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để gửi tin nhắn.')),
      );
      return;
    }

    final result = await ref.read(chatRepositoryProvider).sendMessage(
          reservationId: widget.reservationId,
          senderId: user.id,
          senderName: user.displayName ?? user.phoneNumber,
          text: text,
        );
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => _textController.clear(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).user;
    final messagesAsync = ref.watch(
      chatMessagesStreamProvider(widget.reservationId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trao đổi lấy thực phẩm', style: TextStyle(fontSize: 16)),
            Text(
              'Tự đến lấy (Self-pickup)',
              style: TextStyle(fontSize: 11, color: AppColors.primaryLight),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('Chưa có tin nhắn.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser?.id;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: isMe
                              ? null
                              : Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.text,
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateTimeUtils.formatTime(msg.sentAt),
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white70
                                    : AppColors.textSecondaryLight,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Nhắn tin cho người cho thực phẩm...',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: AppColors.primary,
                    ),
                    onPressed: _handleSend,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
