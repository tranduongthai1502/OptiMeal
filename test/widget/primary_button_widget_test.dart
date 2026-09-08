import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optimeal/core/widgets/primary_button.dart';

void main() {
  testWidgets('PrimaryButton displays label correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: PrimaryButton(
          label: 'Xác nhận giữ chỗ',
          onPressed: null,
        ),
      ),
    );

    expect(find.text('Xác nhận giữ chỗ'), findsOneWidget);
  });
}
