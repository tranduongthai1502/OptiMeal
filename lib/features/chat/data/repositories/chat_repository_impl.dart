import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_message.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Map<String, List<ChatMessage>> _messagesStore = {};
  final Map<String, StreamController<List<ChatMessage>>> _controllers = {};

  @override
  Stream<List<ChatMessage>> getMessagesStream(String reservationId) async* {
    final messages = _messagesStore.putIfAbsent(reservationId, () => []);
    yield List.unmodifiable(messages);
    yield* _controllers
        .putIfAbsent(
          reservationId,
          () => StreamController<List<ChatMessage>>.broadcast(),
        )
        .stream;
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
    _controllers[reservationId]?.add(
      List.unmodifiable(_messagesStore[reservationId]!),
    );
    return Right(newMsg);
  }
}
