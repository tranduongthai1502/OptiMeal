import 'package:flutter_test/flutter_test.dart';
import 'package:optimeal/features/auth/domain/usecases/phone_number_formatter.dart';

void main() {
  group('normalizeVietnamesePhoneNumber', () {
    test('converts a local number to E.164 format', () {
      expect(
        normalizeVietnamesePhoneNumber('0987 654 321'),
        '+84987654321',
      );
    });

    test('keeps an already normalized number in E.164 format', () {
      expect(
        normalizeVietnamesePhoneNumber('+84 987-654-321'),
        '+84987654321',
      );
    });

    test('adds the country prefix when the leading zero is omitted', () {
      expect(normalizeVietnamesePhoneNumber('987654321'), '+84987654321');
    });

    test('rejects numbers with an invalid length or non-digits', () {
      expect(normalizeVietnamesePhoneNumber('098765432'), isNull);
      expect(normalizeVietnamesePhoneNumber('0987654321a'), isNull);
    });
  });
}
