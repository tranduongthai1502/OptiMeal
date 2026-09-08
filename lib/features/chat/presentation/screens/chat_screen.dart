import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
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

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatRepositoryProvider).sendMessage(
          reservationId: widget.reservationId,
          senderId: 'current-user-id',
          senderName: 'Tôi',
          text: text,
        );
    _textController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(chatMessagesStreamProvider(widget.reservationId));

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trao đổi lấy thực phẩm', style: TextStyle(fontSize: 16)),
            Text('Tự đến lấy (Self-pickup)',
                style: TextStyle(fontSize: 11, color: AppColors.primaryLight)),
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
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == 'current-user-id';
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75),
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
                    icon: const Icon(Icons.send_rounded,
                        color: AppColors.primary),
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
