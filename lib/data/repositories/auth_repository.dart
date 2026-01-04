import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth show User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import '../services/supabase_auth_service.dart';
import '../services/esms_service.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebasePhoneAuthService _phoneAuth = FirebasePhoneAuthService();
  final EsmsService _esms = EsmsService();

  // Lưu verificationId để verify OTP
  String? _currentVerificationId;

  // ========== FIREBASE PHONE AUTHENTICATION (PHƯƠNG THỨC CHÍNH) ==========

  /// 1A. Đăng nhập bằng số điện thoại - Bước 1: Gửi OTP
  Future<String> signInWithPhone(String phoneNumber) async {
    try {
      // Validate và format số điện thoại
      if (!_phoneAuth.isValidVietnamesePhone(phoneNumber)) {
        throw '❌ Số điện thoại không hợp lệ.\n\nVui lòng nhập số điện thoại 10 chữ số (bắt đầu 0).';
      }

      final formattedPhone = _phoneAuth.formatPhoneNumber(phoneNumber);
      print('📱 [AuthRepo] Gửi OTP đến: $formattedPhone');

      await _phoneAuth.sendOTP(
        formattedPhone,
        onCodeSent: (verificationId) {
          _currentVerificationId = verificationId;
          print('✅ [AuthRepo] Lưu verificationId');
        },
        onError: (error) {
          print('❌ [AuthRepo] Lỗi gửi OTP: $error');
          throw error;
        },
      );

      return formattedPhone;
    } catch (e) {
      print('❌ [AuthRepo] Lỗi gửi OTP: $e');
      rethrow;
    }
  }

  /// 1B. Đăng nhập bằng số điện thoại - Bước 2: Xác thực OTP
  /// Trả về hasShop (true/false)
  Future<bool> verifyPhoneOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      print('🔐 [AuthRepo] Xác thực OTP cho: $phoneNumber');

      if (_currentVerificationId == null) {
        throw '❌ Không tìm thấy phiên xác thực.\n\nVui lòng gửi lại mã OTP.';
      }

      // Verify OTP với Firebase
      final userCredential = await _phoneAuth.verifyOTP(
        verificationId: _currentVerificationId!,
        smsCode: otpCode,
      );

      final user = userCredential.user;
      if (user == null) {
        throw 'Không thể xác thực OTP';
      }

      print('✅ [AuthRepo] Firebase User ID: ${user.uid}');

      // Đồng bộ user sang Firestore
      await _syncFirebasePhoneUserToFirestore(user, phoneNumber);

      // Kiểm tra đã có shop chưa
      final shopDoc = await _firestore.collection('shops').doc(user.uid).get();

      return shopDoc.exists;
    } catch (e) {
      print('❌ [AuthRepo] Lỗi verify OTP: $e');
      rethrow;
    }
  }

  /// 1C. Đồng bộ Firebase Phone User sang Firestore
  Future<void> _syncFirebasePhoneUserToFirestore(
    firebase_auth.User firebaseUser,
    String phoneNumber,
  ) async {
    try {
      final uid = firebaseUser.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        // Tạo user mới
        print('📝 [AuthRepo] Tạo user mới trong Firestore');
        await _firestore.collection('users').doc(uid).set({
          'phone': phoneNumber,
          'fullName': phoneNumber, // Default, user sẽ cập nhật sau
          'email': firebaseUser.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'authProvider': 'firebase_phone',
          'emailVerified': true, // Phone đã verify rồi
        });

        // Tự động tạo shop mặc định
        await _createDefaultShop(uid, phoneNumber);
      } else {
        // Cập nhật thông tin
        print('🔄 [AuthRepo] Cập nhật user trong Firestore');
        await _firestore.collection('users').doc(uid).update({
          'phone': phoneNumber,
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('❌ [AuthRepo] Lỗi sync Firestore: $e');
      throw Exception('Không thể lưu thông tin người dùng');
    }
  }

  /// 1D. Tạo shop mặc định cho user mới
  Future<void> _createDefaultShop(String uid, String phoneNumber) async {
    try {
      final shopDoc = await _firestore.collection('shops').doc(uid).get();

      if (!shopDoc.exists) {
        print('🏪 [AuthRepo] Tạo shop mặc định');
        await _firestore.collection('shops').doc(uid).set({
          'name': 'My Shop',
          'ownerName': phoneNumber,
          'phone': phoneNumber,
          'email': '',
          'gender': 'Khác',
          'dateOfBirth': '',
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'address': '',
          'description': '',
        });
      }
    } catch (e) {
      print('⚠️ [AuthRepo] Lỗi tạo shop: $e');
      // Không throw, vẫn cho đăng nhập thành công
    }
  }

  /// 1E. Đồng bộ Google User sang Firestore
  Future<void> _syncGoogleUserToFirestore(
    firebase_auth.User firebaseUser,
  ) async {
    try {
      final uid = firebaseUser.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        // Tạo user mới
        print('📝 [AuthRepo] Tạo Google user mới trong Firestore');
        await _firestore.collection('users').doc(uid).set({
          'email': firebaseUser.email ?? '',
          'fullName': firebaseUser.displayName ?? firebaseUser.email ?? 'User',
          'phone': firebaseUser.phoneNumber ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'authProvider': 'google',
          'emailVerified': true, // Google đã verify
        });

        // Tự động tạo shop mặc định
        await _createDefaultShop(uid, firebaseUser.email ?? 'user@gmail.com');
      } else {
        // Cập nhật thông tin
        print('🔄 [AuthRepo] Cập nhật Google user trong Firestore');
        await _firestore.collection('users').doc(uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
          'authProvider': 'google', // Đảm bảo có authProvider
        });
      }
    } catch (e) {
      print('❌ [AuthRepo] Lỗi sync Google user: $e');
      // Không throw để không block login flow
    }
  }

  /// 1F. Đồng bộ Facebook User sang Firestore
  Future<void> _syncFacebookUserToFirestore(
    firebase_auth.User firebaseUser,
  ) async {
    try {
      final uid = firebaseUser.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        // Tạo user mới
        print('📝 [AuthRepo] Tạo Facebook user mới trong Firestore');
        await _firestore.collection('users').doc(uid).set({
          'email': firebaseUser.email ?? '',
          'fullName': firebaseUser.displayName ?? firebaseUser.email ?? 'User',
          'phone': firebaseUser.phoneNumber ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'authProvider': 'facebook',
          'emailVerified': true, // Facebook đã verify
        });

        // Tự động tạo shop mặc định
        await _createDefaultShop(
          uid,
          firebaseUser.email ?? 'user@facebook.com',
        );
      } else {
        // Cập nhật thông tin
        print('🔄 [AuthRepo] Cập nhật Facebook user trong Firestore');
        await _firestore.collection('users').doc(uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
          'authProvider': 'facebook', // Đảm bảo có authProvider
        });
      }
    } catch (e) {
      print('❌ [AuthRepo] Lỗi sync Facebook user: $e');
      // Không throw để không block login flow
    }
  }

  // ========== FIREBASE EMAIL/PASSWORD (GIỮ LẠI) ==========

  // 1. Đăng ký tài khoản mới - TRỰC TIẾP (BỎ OTP)
  Future<bool> signUpWithEmailDirectly({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    UserCredential? userCredential;

    try {
      print('📧 [AuthRepo] Đăng ký với email: $email');

      // Tạo tài khoản Firebase Auth
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      print('✅ [AuthRepo] Đăng ký thành công - UID: $uid');

      // Lưu thông tin user vào Firestore
      await _firestore.collection('users').doc(uid).set({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'gender': gender,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': true, // Bỏ OTP nên set luôn true
        'authProvider': 'email',
      });
      print('✅ [AuthRepo] Đã lưu thông tin user vào Firestore');

      // KHÔNG tạo shop tự động - để user tự setup
      print('ℹ️ [AuthRepo] User cần setup shop sau khi đăng ký');

      return false; // Chưa có shop - cần đến setup_shop
    } on FirebaseAuthException catch (e) {
      print('❌ [AuthRepo] Lỗi đăng ký: ${e.code} - ${e.message}');

      // Nếu đã tạo tài khoản nhưng lỗi ở bước sau, xóa tài khoản
      if (userCredential != null) {
        try {
          await userCredential.user?.delete();
          print('🗑️ [AuthRepo] Đã xóa tài khoản do lỗi');
        } catch (deleteError) {
          print('⚠️ [AuthRepo] Không thể xóa tài khoản: $deleteError');
        }
      }

      throw _handleAuthException(e);
    } catch (e) {
      print('❌ [AuthRepo] Lỗi không xác định: $e');

      // Nếu đã tạo tài khoản nhưng lỗi ở bước sau, xóa tài khoản
      if (userCredential != null) {
        try {
          await userCredential.user?.delete();
          print('🗑️ [AuthRepo] Đã xóa tài khoản do lỗi');
        } catch (deleteError) {
          print('⚠️ [AuthRepo] Không thể xóa tài khoản: $deleteError');
        }
      }

      throw '❌ Đăng ký thất bại.\n\n$e';
    }
  }

  // 2. Đăng nhập - TRỰC TIẾP (BỎ OTP)
  Future<bool> signInWithEmailDirectly({
    required String email,
    required String password,
  }) async {
    try {
      print('📧 [AuthRepo] Đăng nhập với email: $email');

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      print('✅ [AuthRepo] Đăng nhập thành công - UID: $uid');

      // Cập nhật lastLogin và đảm bảo có authProvider
      try {
        await _firestore.collection('users').doc(uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
          'authProvider': 'email', // Đảm bảo có authProvider
        });
      } catch (e) {
        print('⚠️ [AuthRepo] Không thể cập nhật lastLogin: $e');
        // Không throw, vẫn cho login thành công
      }

      // Kiểm tra đã có shop chưa
      DocumentSnapshot shopDoc = await _firestore
          .collection('shops')
          .doc(uid)
          .get();

      bool hasShop = shopDoc.exists;
      print('ℹ️ [AuthRepo] User ${hasShop ? "đã có" : "chưa có"} shop');

      return hasShop;
    } on FirebaseAuthException catch (e) {
      print('❌ [AuthRepo] Lỗi đăng nhập: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  // 1. Đăng ký tài khoản mới bằng Email/Password (CŨ - GIỮ LẠI ĐỂ TƯƠNG THÍCH)
  Future<String> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    UserCredential? userCredential;

    try {
      print('📧 [AuthRepo] Đăng ký với email: $email');

      // Bước 1: Tạo tài khoản Firebase Auth
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      print('✅ [AuthRepo] Đăng ký thành công - UID: $uid');

      // Tạo OTP 6 số ngẫu nhiên
      final otpCode = _generateOTP();
      final expiryTime = DateTime.now().add(Duration(minutes: 10));
      print(
        '🔢 [AuthRepo] OTP Code: $otpCode (Expiry: ${expiryTime.toIso8601String()})',
      );

      // Bước 2: Lưu thông tin user và OTP vào Firestore
      try {
        await _firestore.collection('users').doc(uid).set({
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'gender': gender,
          'dateOfBirth': dateOfBirth.toIso8601String(),
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': false,
          'verificationCode': otpCode,
          'verificationExpiry': expiryTime.toIso8601String(),
        });
        print('✅ [AuthRepo] Đã lưu thông tin user vào Firestore');
      } catch (e) {
        print('⚠️ [AuthRepo] Lỗi lưu Firestore: $e');
        throw Exception('Không thể lưu thông tin người dùng');
      }

      // Bước 3: Gửi OTP qua email bằng Supabase Edge Function
      try {
        final response = await _supabase.functions.invoke(
          'send-verification-otp',
          body: {'email': email, 'fullName': fullName, 'otpCode': otpCode},
        );

        if (response.status == 200) {
          print('📨 [AuthRepo] Đã gửi OTP tới $email');
        } else {
          print('⚠️ [AuthRepo] Lỗi gửi OTP: ${response.data}');
        }
      } catch (e) {
        print('⚠️ [AuthRepo] Lỗi gửi email OTP: $e');
        // Không throw lỗi, vẫn cho đăng ký thành công
      }

      // KHÔNG sign out ở đây - giữ user đăng nhập để có quyền đọc Firestore khi verify OTP
      print('ℹ️ [AuthRepo] Giữ user đăng nhập để verify OTP');

      return uid; // Trả về userId để truyền sang VerifyOTP screen
    } on FirebaseAuthException catch (e) {
      print('❌ [AuthRepo] Lỗi đăng ký: ${e.code} - ${e.message}');

      // Nếu đã tạo tài khoản nhưng lỗi ở bước sau, xóa tài khoản
      if (userCredential != null) {
        try {
          await userCredential.user?.delete();
          print('🗑️ [AuthRepo] Đã xóa tài khoản do lỗi');
        } catch (deleteError) {
          print('⚠️ [AuthRepo] Không thể xóa tài khoản: $deleteError');
        }
      }

      throw _handleAuthException(e);
    } catch (e) {
      print('❌ [AuthRepo] Lỗi không xác định: $e');

      // Nếu đã tạo tài khoản nhưng lỗi ở bước sau, xóa tài khoản
      if (userCredential != null) {
        try {
          await userCredential.user?.delete();
          print('🗑️ [AuthRepo] Đã xóa tài khoản do lỗi');
        } catch (deleteError) {
          print('⚠️ [AuthRepo] Không thể xóa tài khoản: $deleteError');
        }
      }

      throw '❌ Đăng ký thất bại.\n\n$e';
    }
  }

  // 2. Đăng nhập bằng Email/Password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('📧 [AuthRepo] Đăng nhập với email: $email');

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      print('✅ [AuthRepo] Đăng nhập thành công - UID: $uid');

      // Kiểm tra email đã được xác minh chưa (từ Firestore, không check Firebase Auth)
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw '❌ Không tìm thấy thông tin tài khoản.\n\nVui lòng đăng ký lại.';
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final emailVerified = userData['emailVerified'] as bool? ?? false;

      if (!emailVerified) {
        await _auth.signOut();
        throw '⚠️ Email chưa được xác minh.\n\nVui lòng nhập mã OTP đã gửi đến email của bạn để xác thực tài khoản.';
      }

      // Kiểm tra đã có shop chưa
      DocumentSnapshot shopDoc = await _firestore
          .collection('shops')
          .doc(uid)
          .get();

      if (!shopDoc.exists) {
        // Chưa có shop - Tự động tạo shop với tên mặc định
        print('🏪 [AuthRepo] Tự động tạo shop từ thông tin đã lưu');

        try {
          // Tạo tên shop mặc định từ tên người dùng
          String defaultShopName = '${userData['fullName'] ?? 'My'} Shop';

          await _firestore.collection('shops').doc(uid).set({
            'name': defaultShopName,
            'ownerName': userData['fullName'] ?? '',
            'phone': userData['phone'] ?? '',
            'email': userData['email'] ?? email,
            'gender': userData['gender'] ?? 'Khác',
            'dateOfBirth': userData['dateOfBirth'] ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'isActive': true,
            'address': '', // User sẽ cập nhật sau
            'description': '', // User sẽ cập nhật sau
          });

          // Cập nhật emailVerified trong users collection
          await _firestore.collection('users').doc(uid).update({
            'emailVerified': true,
            'shopCreated': true,
          });

          print('✅ [AuthRepo] Đã tạo shop thành công: $defaultShopName');
          return true; // Đã có shop
        } catch (e) {
          print('⚠️ [AuthRepo] Lỗi tạo shop tự động: $e');
          // Nếu lỗi tạo shop, vẫn cho đăng nhập và chuyển Setup Shop
          return false;
        }
      }

      return shopDoc.exists; // True: Có shop, False: Chưa có
    } on FirebaseAuthException catch (e) {
      print('❌ [AuthRepo] Lỗi đăng nhập: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      // Re-throw string errors (như email chưa verify)
      rethrow;
    }
  }

  // 3. Đăng nhập bằng Google
  Future<bool> signInWithGoogle() async {
    try {
      print('🔵 [AuthRepo] Bắt đầu đăng nhập Google');

      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('⚠️ [AuthRepo] User đã hủy đăng nhập Google');
        throw '⚠️ Đăng nhập Google đã bị hủy.\n\nVui lòng thử lại.';
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final user = userCredential.user!;
      String uid = user.uid;

      print('✅ [AuthRepo] Google Sign In thành công - UID: $uid');

      // Đồng bộ user sang Firestore
      await _syncGoogleUserToFirestore(user);

      // Kiểm tra đã có shop chưa
      DocumentSnapshot shopDoc = await _firestore
          .collection('shops')
          .doc(uid)
          .get();
      return shopDoc.exists;
    } catch (e) {
      print('❌ [AuthRepo] Lỗi Google Sign In: $e');
      if (e.toString().contains('đã bị hủy') ||
          e.toString().contains('cancelled')) {
        throw '⚠️ Đăng nhập Google đã bị hủy.\n\nVui lòng thử lại.';
      }
      throw '❌ Đăng nhập Google thất bại.\n\nVui lòng kiểm tra kết nối và thử lại.';
    }
  }

  // 4. Đăng nhập bằng Facebook
  Future<bool> signInWithFacebook() async {
    try {
      print('🔵 [AuthRepo] Bắt đầu đăng nhập Facebook');

      // Trigger Facebook Sign In
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // Get access token
        final AccessToken accessToken = result.accessToken!;

        // Create Firebase credential
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );

        // Sign in to Firebase
        UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        final user = userCredential.user!;
        String uid = user.uid;

        print('✅ [AuthRepo] Facebook Sign In thành công - UID: $uid');

        // Đồng bộ user sang Firestore
        await _syncFacebookUserToFirestore(user);

        // Kiểm tra đã có shop chưa
        DocumentSnapshot shopDoc = await _firestore
            .collection('shops')
            .doc(uid)
            .get();
        return shopDoc.exists;
      } else if (result.status == LoginStatus.cancelled) {
        print('⚠️ [AuthRepo] User đã hủy đăng nhập Facebook');
        throw '⚠️ Đăng nhập Facebook đã bị hủy.\n\nVui lòng thử lại.';
      } else {
        print('❌ [AuthRepo] Facebook login failed: ${result.message}');
        throw '❌ Đăng nhập Facebook thất bại.\n\n${result.message ?? "Vui lòng thử lại."}';
      }
    } catch (e) {
      print('❌ [AuthRepo] Lỗi Facebook Sign In: $e');
      if (e.toString().contains('đã bị hủy') ||
          e.toString().contains('cancelled')) {
        rethrow;
      }
      throw '❌ Đăng nhập Facebook thất bại.\n\nVui lòng kiểm tra kết nối và thử lại.';
    }
  }

  // 5. Gửi lại email xác minh
  Future<void> resendVerificationEmail(String email, String password) async {
    try {
      print('📨 [AuthRepo] Gửi lại email xác minh cho: $email');

      // Đăng nhập tạm để gửi email
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user!.emailVerified) {
        await _auth.signOut();
        throw '✅ Email đã được xác minh.\n\nBạn có thể đăng nhập bình thường.';
      }

      await userCredential.user!.sendEmailVerification();
      await _auth.signOut();

      print('✅ [AuthRepo] Đã gửi lại email xác minh');
    } on FirebaseAuthException catch (e) {
      print('❌ [AuthRepo] Lỗi gửi lại email: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      // Re-throw string errors
      rethrow;
    }
  }

  // 6. Xử lý lỗi Firebase Auth sang tiếng Việt
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return '❌ Email này đã được sử dụng.\n\nVui lòng đăng nhập hoặc sử dụng email khác.';
      case 'invalid-email':
        return '❌ Email không hợp lệ.\n\nVui lòng kiểm tra lại định dạng email.';
      case 'operation-not-allowed':
        return '❌ Đăng nhập bằng email chưa được kích hoạt.\n\nVui lòng liên hệ quản trị viên.';
      case 'weak-password':
        return '❌ Mật khẩu quá yếu.\n\nVui lòng sử dụng mật khẩu mạnh hơn (ít nhất 6 ký tự).';
      case 'user-disabled':
        return '❌ Tài khoản đã bị vô hiệu hóa.\n\nVui lòng liên hệ quản trị viên.';
      case 'user-not-found':
        return '❌ Email chưa được đăng ký.\n\nVui lòng đăng ký tài khoản mới.';
      case 'wrong-password':
        return '❌ Mật khẩu không chính xác.\n\nVui lòng thử lại hoặc chọn "Quên mật khẩu".';
      case 'invalid-credential':
        return '❌ Thông tin đăng nhập không đúng.\n\nVui lòng kiểm tra lại email và mật khẩu.';
      case 'too-many-requests':
        return '⚠️ Quá nhiều lần thử đăng nhập.\n\nVui lòng thử lại sau vài phút.';
      case 'network-request-failed':
        return '📡 Không có kết nối mạng.\n\nVui lòng kiểm tra kết nối Internet và thử lại.';
      default:
        return '❌ Lỗi: ${e.message ?? "Không xác định"}\n\nVui lòng thử lại sau.';
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    await _auth.signOut();
    await _phoneAuth.signOut();
  }

  // Lấy User hiện tại
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Expose Firestore instance
  FirebaseFirestore get firestore => _firestore;

  // 7. Generate OTP 6 số
  String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // 8. Verify OTP code
  Future<bool> verifyOTP({
    required String userId,
    required String otpCode,
  }) async {
    try {
      print('🔐 [AuthRepo] Xác thực OTP cho userId: $userId');

      // Lấy user document trực tiếp bằng userId
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('Không tìm thấy tài khoản');
      }

      final userData = userDoc.data()!;

      // Kiểm tra OTP
      final storedOTP = userData['verificationCode'] as String?;
      final expiryStr = userData['verificationExpiry'] as String?;

      print('🔍 [AuthRepo] Stored OTP: $storedOTP, Input OTP: $otpCode');
      print('🔍 [AuthRepo] Expiry: $expiryStr');

      if (storedOTP == null || expiryStr == null) {
        throw Exception('Không tìm thấy mã xác thực');
      }

      final expiryTime = DateTime.parse(expiryStr);
      final now = DateTime.now();

      print(
        '🔍 [AuthRepo] Now: ${now.toIso8601String()}, Expiry: ${expiryTime.toIso8601String()}',
      );

      // Kiểm tra hết hạn
      if (now.isAfter(expiryTime)) {
        throw Exception(
          'Mã xác thực đã hết hạn (${now.difference(expiryTime).inMinutes} phút trước)',
        );
      }

      // Kiểm tra OTP đúng không
      if (storedOTP != otpCode) {
        throw Exception(
          'Mã xác thực không đúng. Bạn nhập: "$otpCode", Đúng là: "$storedOTP"',
        );
      }

      // Xác thực thành công -> Cập nhật Firestore
      await _firestore.collection('users').doc(userId).update({
        'emailVerified': true,
        'verificationCode': FieldValue.delete(),
        'verificationExpiry': FieldValue.delete(),
      });

      print('✅ [AuthRepo] Xác thực OTP thành công');
      return true;
    } catch (e) {
      print('❌ [AuthRepo] Lỗi xác thực OTP: $e');
      throw e;
    }
  }

  // 9. Gửi lại OTP
  Future<void> resendOTP({
    required String userId,
    required String email,
    required String fullName,
  }) async {
    try {
      print('📧 [AuthRepo] Gửi lại OTP cho userId: $userId');

      // Tạo OTP mới
      final otpCode = _generateOTP();
      final expiryTime = DateTime.now().add(Duration(minutes: 10));

      // Cập nhật OTP mới
      await _firestore.collection('users').doc(userId).update({
        'verificationCode': otpCode,
        'verificationExpiry': expiryTime.toIso8601String(),
      });

      // Gửi email
      final response = await _supabase.functions.invoke(
        'send-verification-otp',
        body: {'email': email, 'fullName': fullName, 'otpCode': otpCode},
      );

      if (response.status == 200) {
        print('📨 [AuthRepo] Đã gửi lại OTP tới $email');
      } else {
        throw Exception('Không thể gửi email');
      }
    } catch (e) {
      print('❌ [AuthRepo] Lỗi gửi lại OTP: $e');
      throw e;
    }
  }
}
