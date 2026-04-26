import 'dart:io';
import 'package:test/test.dart';
import '../src/core/platform_paths.dart';

void main() {
  group('userHome', () {
    test('returns a non-empty string on a normally-configured machine', () {
      // CI runners and developer laptops always set one of HOME / USERPROFILE.
      final home = userHome();
      expect(home, isNotNull);
      expect(home, isNotEmpty);
    });

    test('userHomeOrCwd never returns null', () {
      expect(userHomeOrCwd(), isNotEmpty);
    });
  });

  group('tempDir', () {
    test('returns the system temp dir, which exists', () {
      final t = tempDir();
      expect(t, isNotEmpty);
      expect(Directory(t).existsSync(), isTrue);
    });

    test('matches Directory.systemTemp.path', () {
      expect(tempDir(), equals(Directory.systemTemp.path));
    });
  });
}
