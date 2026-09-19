import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';

/// Central utility for graceful error handling.
/// Logs full technical details (real issue, error type, stack trace) to debug/backend logs,
/// while providing clean, friendly, localized messages to tailors and customers.
abstract final class ErrorUtils {
  /// Logs the real error details to the debug/backend console,
  /// and returns a clean, user-friendly message.
  static String getFriendlyErrorMessage(
    Object error, {
    StackTrace? stackTrace,
    String? contextTag,
    AppLocalizations? l10n,
  }) {
    final tag = contextTag != null ? '[$contextTag]' : '[SYSTEM_ERROR]';

    // 1. Log the full real issue for developers / backend diagnostics
    debugPrint('$tag Real technical issue: $error');
    if (stackTrace != null) {
      debugPrint('$tag StackTrace:\n$stackTrace');
    }

    final errStr = error.toString().toLowerCase();

    // 2. Network & Connection issues (SocketException, timeout, host lookup, offline)
    if (errStr.contains('socketexception') ||
        errStr.contains('failed host lookup') ||
        errStr.contains('clientexception') ||
        errStr.contains('timeoutexception') ||
        errStr.contains('connection refused') ||
        errStr.contains('connection reset') ||
        errStr.contains('connection closed') ||
        errStr.contains('network is unreachable') ||
        errStr.contains('handshakeexception') ||
        errStr.contains('failed to connect') ||
        errStr.contains('no internet') ||
        errStr.contains('network error') ||
        errStr.contains('offline')) {
      return l10n?.connectionError ??
          'Unable to connect. Please check your internet connection and try again.';
    }

    // 3. Invalid credentials
    if (errStr.contains('invalid login credentials') ||
        errStr.contains('invalid_grant') ||
        errStr.contains('invalid_credentials')) {
      return l10n?.invalidCredentials ??
          'Incorrect email or password. Please try again.';
    }

    // 4. Server issues (5xx)
    if (errStr.contains('500') ||
        errStr.contains('502') ||
        errStr.contains('503') ||
        errStr.contains('504') ||
        errStr.contains('internal server error') ||
        errStr.contains('bad gateway') ||
        errStr.contains('service unavailable')) {
      return l10n?.serverError ??
          'Our servers are temporarily unavailable. Please try again in a few moments.';
    }

    // 5. Fallback generic graceful message
    return l10n?.genericError ?? 'Something went wrong. Please try again.';
  }
}
