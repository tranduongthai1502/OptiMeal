String? normalizeVietnamesePhoneNumber(String input) {
  final compact = input.replaceAll(RegExp(r'[\s().-]'), '');
  final digits = compact.startsWith('+') ? compact.substring(1) : compact;

  if (!RegExp(r'^\d+$').hasMatch(digits)) return null;

  final internationalDigits = digits.startsWith('84')
      ? digits
      : digits.startsWith('0')
          ? '84${digits.substring(1)}'
          : '84$digits';

  if (!RegExp(r'^84\d{9}$').hasMatch(internationalDigits)) return null;
  return '+$internationalDigits';
}
