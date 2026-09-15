import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';

class ChatMessage {
  final String id;
  final String reservationId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.reservationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
    this.isRead = false,
  });
}

abstract class ChatRepository {
  Stream<List<ChatMessage>> getMessagesStream(String reservationId);

  Future<Either<Failure, ChatMessage>> sendMessage({
    required String reservationId,
    required String senderId,
    required String senderName,
    required String text,
  });
}
