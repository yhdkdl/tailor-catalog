import 'package:flutter_test/flutter_test.dart';
import 'package:tailor_catalog/features/upload/cloudinary_service.dart';

void main() {
  group('UploadRateLimiter Tests', () {
    test('allows uploads within maximum limit', () {
      final limiter = UploadRateLimiter(maxUploadsPerWindow: 3);

      expect(limiter.canUpload(), isTrue);
      limiter.checkAndRecordUpload();
      limiter.checkAndRecordUpload();
      limiter.checkAndRecordUpload();

      expect(limiter.canUpload(), isFalse);
    });

    test('throws UploadRateLimitException when exceeding limit', () {
      final limiter = UploadRateLimiter(maxUploadsPerWindow: 2);

      limiter.checkAndRecordUpload();
      limiter.checkAndRecordUpload();

      expect(
        () => limiter.checkAndRecordUpload(),
        throwsA(isA<UploadRateLimitException>()),
      );
    });

    test('reset clears recorded timestamps', () {
      final limiter = UploadRateLimiter(maxUploadsPerWindow: 2);

      limiter.checkAndRecordUpload();
      limiter.checkAndRecordUpload();
      expect(limiter.canUpload(), isFalse);

      limiter.reset();
      expect(limiter.canUpload(), isTrue);
      expect(() => limiter.checkAndRecordUpload(), returnsNormally);
    });
  });
}
