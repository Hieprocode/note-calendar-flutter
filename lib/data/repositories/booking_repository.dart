import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // HÀM CHUẨN: Chỉ nhận 1 tham số là shopId
  Stream<List<BookingModel>> getBookingsStream(String shopId) {
    return _firestore
        .collection('bookings')
        .where('shop_id', isEqualTo: shopId)
        // Sắp xếp: Cái nào sắp diễn ra thì nằm trên cùng
        .orderBy('start_time', descending: false) 
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Hàm cập nhật trạng thái (Dùng cho sau này)
  Future<void> updateStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status
    });
  }
}