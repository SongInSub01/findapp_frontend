import 'dart:math';

abstract final class Formatters {
  static String money(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      final reverseIndex = digits.length - index;
      buffer.write(digits[index]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return '${buffer.toString()}원';
  }

  static String nowTimeLabel() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final prefix = now.hour >= 12 ? '오후' : '오전';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$prefix $hour:$minute';
  }

  static String uniqueId(String prefix) {
    final random = Random();
    return '$prefix${DateTime.now().microsecondsSinceEpoch}${random.nextInt(99)}';
  }
}
