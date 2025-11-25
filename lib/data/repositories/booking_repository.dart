// lib/data/repositories/booking_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy danh sách booking realtime theo shop
  Stream<List<BookingModel>> getBookingsStream(String shopId) {
    return _firestore
        .collection('bookings')
        .where('shop_id', isEqualTo: shopId)
        .orderBy('start_time', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// THÊM MỚI: Thêm booking và trả về DocumentReference để lấy ID
  Future<DocumentReference> addBooking(BookingModel booking) async {
    return await _firestore.collection('bookings').add(booking.toJson());
  }

  /// Cập nhật trạng thái (dùng sau này)
  Future<void> updateStatus(String bookingId, String status) async {
    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status});
  }
}