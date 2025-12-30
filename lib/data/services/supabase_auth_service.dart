import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/// Service xử lý Phone Authentication với Firebase
class FirebasePhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lưu verificationId để dùng khi verify OTP
  String? _verificationId;
  int? _resendToken;

  /// 1. Gửi OTP đến số điện thoại
  /// [phoneNumber] phải có định dạng quốc tế: +84 xxx xxx xxx
  Future<void> sendOTP(
    String phoneNumber, {
    Function(String verificationId)? onCodeSent,
    Function(String error)? onError,
  }) async {
    try {
      print('📱 [FirebasePhoneAuth] Gửi OTP đến: $phoneNumber');

      final completer = Completer<void>();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (trên Android, nếu SMS được detect tự động)
          print('✅ [FirebasePhoneAuth] Auto-verification completed');
          try {
            await _auth.signInWithCredential(credential);
            completer.complete();
          } catch (e) {
            print('❌ [FirebasePhoneAuth] Auto sign-in failed: $e');
            completer.completeError(e);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ [FirebasePhoneAuth] Verification failed: ${e.code}');
          final errorMessage = _handleFirebaseError(e);
          onError?.call(errorMessage);
          completer.completeError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          print('✅ [FirebasePhoneAuth] Code sent - ID: $verificationId');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent?.call(verificationId);
          completer.complete();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏱️ [FirebasePhoneAuth] Auto retrieval timeout');
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );

      await completer.future;
    } catch (e) {
      print('❌ [FirebasePhoneAuth] Lỗi gửi OTP: $e');
      rethrow;
    }
  }

  /// 2. Xác thực OTP
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      print('🔐 [FirebasePhoneAuth] Xác thực OTP');

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      print(
          '✅ [FirebasePhoneAuth] Xác thực thành công - User ID: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ [FirebasePhoneAuth] Lỗi xác thực OTP: ${e.code}');
      throw _handleFirebaseError(e);
    } catch (e) {
      print('❌ [FirebasePhoneAuth] Lỗi không xác định: $e');
      rethrow;
    }
  }

  /// 3. Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  /// 4. Đăng xuất
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ [FirebasePhoneAuth] Đăng xuất thành công');
    } catch (e) {
      print('❌ [FirebasePhoneAuth] Lỗi đăng xuất: $e');
      rethrow;
    }
  }

  /// 5. Lấy verificationId hiện tại
  String? get verificationId => _verificationId;

  /// 6. Kiểm tra định dạng số điện thoại Việt Nam
  String formatPhoneNumber(String phone) {
    // Loại bỏ khoảng trắng và ký tự đặc biệt
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Nếu bắt đầu bằng 0, chuyển thành +84
    if (cleaned.startsWith('0')) {
      cleaned = '+84${cleaned.substring(1)}';
    }

    // Nếu chưa có +84, thêm vào
    if (!cleaned.startsWith('+84')) {
      cleaned = '+84$cleaned';
    }

    return cleaned;
  }

  /// 7. Validate phone number
  bool isValidVietnamesePhone(String phone) {
    // Số điện thoại Việt Nam: 10 chữ số, bắt đầu 0
    final regex = RegExp(r'^0[3|5|7|8|9][0-9]{8}$');
    return regex.hasMatch(phone);
  }

  /// 8. Xử lý lỗi Firebase Auth
  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return '❌ Số điện thoại không hợp lệ.\n\nVui lòng kiểm tra lại định dạng.';
      case 'invalid-verification-code':
        return '❌ Mã OTP không đúng.\n\nVui lòng kiểm tra lại mã 6 số.';
      case 'invalid-verification-id':
        return '❌ Phiên xác thực không hợp lệ.\n\nVui lòng gửi lại mã OTP.';
      case 'session-expired':
        return '⏱️ Mã OTP đã hết hạn.\n\nVui lòng gửi lại mã mới.';
      case 'quota-exceeded':
        return '⚠️ Đã vượt quá giới hạn SMS.\n\nVui lòng thử lại sau.';
      case 'too-many-requests':
        return '⚠️ Quá nhiều yêu cầu.\n\nVui lòng đợi vài phút rồi thử lại.';
      case 'network-request-failed':
        return '📡 Không có kết nối mạng.\n\nVui lòng kiểm tra Internet.';
      case 'user-disabled':
        return '❌ Tài khoản đã bị vô hiệu hóa.\n\nVui lòng liên hệ hỗ trợ.';
      default:
        return '❌ Lỗi: ${e.message ?? "Không xác định"}\n\nVui lòng thử lại.';
    }
  }
}
