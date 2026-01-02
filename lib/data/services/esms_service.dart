import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

/// Service gửi SMS OTP qua eSMS.vn (Việt Nam)
/// Đăng ký tại: https://esms.vn
/// Miễn phí 30 SMS test, thanh toán qua chuyển khoản ngân hàng
class EsmsService {
  // API Credentials - Lấy từ https://esms.vn/Dashboard
  static const String API_KEY = 'YOUR_ESMS_API_KEY'; // Thay bằng key của bạn
  static const String SECRET_KEY = 'YOUR_ESMS_SECRET_KEY'; // Thay bằng secret của bạn
  static const String BRANDNAME = 'Baotrixemay'; // Tên brandname (mặc định dùng này để test)

  final String _baseUrl = 'http://rest.esms.vn/MainService.svc/json';

  /// Gửi SMS OTP
  Future<bool> sendOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      // Format phone: 0987654321 (không cần +84)
      String phone = phoneNumber.replaceAll('+84', '0');
      
      String message = 'Ma xac thuc cua ban la: $otpCode. Ma co hieu luc trong 10 phut.';
      
      print('📱 [eSMS] Gửi OTP đến: $phone');

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/SendMultipleMessage_V4_get'
          '?ApiKey=$API_KEY'
          '&SecretKey=$SECRET_KEY'
          '&Phone=$phone'
          '&Content=${Uri.encodeComponent(message)}'
          '&Brandname=$BRANDNAME'
          '&SmsType=2', // Type 2 = OTP
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['CodeResult'] == '100') {
          print('✅ [eSMS] Gửi SMS thành công - ID: ${data['SMSID']}');
          return true;
        } else {
          print('❌ [eSMS] Lỗi: ${data['ErrorMessage']}');
          throw Exception(data['ErrorMessage'] ?? 'Không thể gửi SMS');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [eSMS] Lỗi gửi SMS: $e');
      rethrow;
    }
  }

  /// Kiểm tra số dư tài khoản
  Future<Map<String, dynamic>> checkBalance() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/GetBalance/$API_KEY/$SECRET_KEY',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('💰 [eSMS] Số dư: ${data['Balance']} VNĐ');
        return data;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [eSMS] Lỗi kiểm tra số dư: $e');
      rethrow;
    }
  }

  /// Generate OTP 6 số
  String generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}
