import 'package:buahaya/core/utils/formatters.dart';
import 'package:buahaya/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('email validator', () {
    expect(Validators.isEmail('a@b.co'), isTrue);
    expect(Validators.isEmail('bukan-email'), isFalse);
  });

  test('password needs 8 chars and a special character', () {
    expect(Validators.isStrongPassword('abcdefgh!'), isTrue);
    expect(Validators.isStrongPassword('abcdefgh'), isFalse);
  });

  test('duration formatter', () {
    expect(formatDuration(const Duration(minutes: 42)), '42 min');
    expect(formatDuration(const Duration(minutes: 65)), '1 h 5 min');
  });
}
