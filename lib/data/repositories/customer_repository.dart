import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Dùng biến hằng số để tránh gõ sai chính tả 'customers' thành 'customer'
  final String _collection = 'customers';

  // 1. TÌM KIẾM: Tìm khách lẻ bằng SĐT (Dùng khi tạo booking)
  Future<CustomerModel?> findCustomerByPhone(String phone, String shopId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('shop_id', isEqualTo: shopId)
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return CustomerModel.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      print("Lỗi tìm khách: $e");
      return null;
    }
  }

  // 2. LƯU KHÁCH HÀNG (Gộp chung Tạo mới & Cập nhật thông tin)
  // Dùng SetOptions(merge: true) là cách an toàn nhất: 
  // - Nếu chưa có -> Tạo mới.
  // - Nếu có rồi -> Chỉ cập nhật các trường thay đổi, giữ nguyên các trường khác (như total_bookings).
  Future<void> saveCustomer(CustomerModel customer) async {
    await _firestore.collection(_collection).doc(customer.id).set(
      customer.toJson(),
      SetOptions(merge: true),
    );
  }

  // 3. CẬP NHẬT SỐ LIỆU (Chạy ngầm khi booking thành công)
  Future<void> incrementBookingCount(String customerId) async {
    try {
      await _firestore.collection(_collection).doc(customerId).update({
        'total_bookings': FieldValue.increment(1),
        'last_booking_date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Lỗi cộng dồn khách: $e");
    }
  }

  // 4. LẤY DANH SÁCH (Stream - Realtime) -> Dùng cho màn hình Quản lý Khách
  Stream<List<CustomerModel>> getCustomersStream(String shopId) {
    return _firestore
        .collection(_collection)
        .where('shop_id', isEqualTo: shopId)
        .orderBy('last_booking_date', descending: true) // Khách mới ghé hiện lên đầu
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomerModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // 5. XÓA KHÁCH HÀNG
  Future<void> deleteCustomer(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}