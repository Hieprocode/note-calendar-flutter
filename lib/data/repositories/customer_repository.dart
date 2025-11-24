// lib/data/repositories/customer_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tìm khách hàng bằng số điện thoại
  Future<CustomerModel?> findCustomerByPhone(String phone, String shopId) async {
    final snapshot = await _firestore
        .collection('customers')
        .where('shop_id', isEqualTo: shopId)
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return CustomerModel.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
    }
    return null;
  }

  // Tạo hồ sơ khách mới
  Future<void> createCustomer(CustomerModel customer) async {
    // Dùng số điện thoại làm ID luôn cho dễ tìm và tránh trùng lặp
    await _firestore.collection('customers').doc(customer.phone).set(customer.toJson());
  }

  // Cập nhật số liệu (khi khách đặt thêm đơn)
  Future<void> updateCustomerStats(String customerId) async {
    await _firestore.collection('customers').doc(customerId).update({
      'total_bookings': FieldValue.increment(1),
      'last_booking_date': FieldValue.serverTimestamp(),
    });
  }
}