import 'dart:async';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_message.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Map<String, List<ChatMessage>> _messagesStore = {};
  final StreamController<List<ChatMessage>> _controller = StreamController<List<ChatMessage>>.broadcast();

  @override
  Stream<List<ChatMessage>> getMessagesStream(String reservationId) {
    if (!_messagesStore.containsKey(reservationId)) {
      _messagesStore[reservationId] = [
        ChatMessage(
          id: 'msg-1',
          reservationId: reservationId,
          senderId: 'donor-01',
          senderName: 'Tous Les Jours Hai Bà Trưng',
          text: 'Chào bạn! Bánh mì của bạn đã được đóng gói sẵn trong túi giấy. Bạn có thể ghé quầy trước 18:30 nhé.',
          sentAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ];
    }
    return Stream.value(_messagesStore[reservationId]!);
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String reservationId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final newMsg = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      reservationId: reservationId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      sentAt: DateTime.now(),
    );
    _messagesStore.putIfAbsent(reservationId, () => []).add(newMsg);
    _controller.add(_messagesStore[reservationId]!);
    return Right(newMsg);
  }
}
