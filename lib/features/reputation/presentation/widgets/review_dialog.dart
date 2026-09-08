import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/review.dart';

class ReviewDialog extends StatefulWidget {
  final String reservationId;
  final String targetUserId;
  final String targetUserName;
  final Function(Review review) onSubmit;

  const ReviewDialog({
    super.key,
    required this.reservationId,
    required this.targetUserId,
    required this.targetUserName,
    required this.onSubmit,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int _rating = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Đánh giá ${widget.targetUserName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Giao dịch tự lấy thực phẩm diễn ra thế nào?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  icon: Icon(
                    starIndex <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () => setState(() => _rating = starIndex),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhận xét về độ tươi ngon, đúng hẹn, thái độ...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Bỏ qua'),
        ),
        ElevatedButton(
          onPressed: () {
            final review = Review(
              id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
              reservationId: widget.reservationId,
              reviewerId: 'current-user-id',
              targetUserId: widget.targetUserId,
              rating: _rating,
              comment: _commentController.text.trim(),
              createdAt: DateTime.now(),
            );
            widget.onSubmit(review);
            Navigator.pop(context);
          },
          child: const Text('Gửi đánh giá'),
        ),
      ],
    );
  }
}
