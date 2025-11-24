import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Biến lưu verificationId để dùng khi nhập OTP
  String? _verificationId;

  // 1. Gửi yêu cầu OTP đến số điện thoại
  Future<void> sendOTP({
    required String phone,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android tự động xác thực (ít khi xảy ra nếu chưa config SHA)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? "Lỗi xác thực số điện thoại");
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // 2. Xác thực mã OTP người dùng nhập
  // Trả về: True (User cũ - Đã có Shop), False (User mới - Chưa có Shop)
  Future<bool> verifyOTP(String otp) async {
    if (_verificationId == null) throw Exception("Chưa có mã xác thực");

    // Tạo credential
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    // Đăng nhập
    UserCredential userCredential = await _auth.signInWithCredential(credential);
    String uid = userCredential.user!.uid;

    // 3. Kiểm tra ngay xem UID này đã có Shop chưa?
    DocumentSnapshot shopDoc = await _firestore.collection('shops').doc(uid).get();
    
    return shopDoc.exists; // True: Có rồi, False: Chưa có
  }

  // Đăng xuất
  Future<void> logout() async {
    await _auth.signOut();
  }
  
  // Lấy User hiện tại
  User? get currentUser => _auth.currentUser;
}