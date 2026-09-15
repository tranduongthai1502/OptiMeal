import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optimeal/app.dart';

void main() {
  testWidgets('App smoke test - initializes OptiMealApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OptiMealApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.byType(OptiMealApp), findsOneWidget);
  });
}
