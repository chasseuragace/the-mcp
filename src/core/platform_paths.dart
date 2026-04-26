// Cross-platform helpers for resolving the user's home directory and a
// writable temp directory. macOS/Linux use $HOME and /tmp; Windows uses
// %USERPROFILE% and the system-resolved temp directory.

import 'dart:io';

/// Returns the user's home directory, or null if it can't be resolved.
///
/// Order: `HOME` (Unix) → `USERPROFILE` (Windows) → `HOMEDRIVE` + `HOMEPATH`.
String? userHome() {
  final env = Platform.environment;
  final home = env['HOME'];
  if (home != null && home.isNotEmpty) return home;

  final userProfile = env['USERPROFILE'];
  if (userProfile != null && userProfile.isNotEmpty) return userProfile;

  final drive = env['HOMEDRIVE'];
  final path = env['HOMEPATH'];
  if (drive != null && path != null && drive.isNotEmpty && path.isNotEmpty) {
    return '$drive$path';
  }

  return null;
}

/// Returns the user's home directory, or the current working directory if
/// the home directory can't be resolved. Never returns null.
String userHomeOrCwd() => userHome() ?? Directory.current.path;

/// Returns a writable temp directory path. Uses `Directory.systemTemp` so
/// callers don't need to hardcode `/tmp` (which doesn't exist on Windows).
String tempDir() => Directory.systemTemp.path;
