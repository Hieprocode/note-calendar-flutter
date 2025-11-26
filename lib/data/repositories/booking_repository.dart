// lib/data/repositories/booking_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Nên dùng biến này để tránh gõ sai chính tả ở nhiều chỗ
  final String _collection = 'bookings'; 

  // 1. Lấy danh sách booking realtime
  Stream<List<BookingModel>> getBookingsStream(String shopId) {
    return _firestore
        .collection(_collection)
        .where('shop_id', isEqualTo: shopId)
        .orderBy('start_time', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // 2. THÊM MỚI (Đã sửa tên từ addBooking -> createBooking)
  Future<void> createBooking(BookingModel booking) async {
    await _firestore.collection(_collection).add(booking.toJson());
  }

  // 3. Cập nhật trạng thái
  Future<void> updateStatus(String bookingId, String status) async {
    await _firestore
        .collection(_collection)
        .doc(bookingId)
        .update({'status': status});
  }

  // 4. Cập nhật toàn bộ (Sửa)
  Future<void> updateBooking(BookingModel booking) async {
    if (booking.id == null) return;
    await _firestore.collection(_collection).doc(booking.id).update(booking.toJson());
  }

  // 5. Xóa lịch
  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection(_collection).doc(bookingId).delete();
  }
}