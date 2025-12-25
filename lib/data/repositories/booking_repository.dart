// lib/data/repositories/booking_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
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

  // 2. THÊM MỚI + GỬI NOTIFICATION
  Future<void> createBooking(BookingModel booking) async {
    try {
      // Tạo booking
      await _firestore.collection(_collection).add(booking.toJson());
      
      // ✅ Gửi notification ngay từ app
      await _sendNotificationToShop(
        shopId: booking.shopId,
        title: "📅 Có khách mới đặt lịch!",
        body: "${booking.customerName} - ${booking.serviceName}",
        type: "new_booking",
      );
      
      print("--> Booking tạo thành công + gửi notification");
    } catch (e) {
      print("--> Lỗi tạo booking: $e");
      rethrow;
    }
  }

  // 3. Cập nhật trạng thái
  Future<void> updateStatus(String bookingId, String status) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(bookingId)
          .update({'status': status});
      
      // Chỉ gửi notification khi completed hoặc checked_in (đã đến)
      if (status == 'completed' || status == 'checked_in') {
        final bookingDoc = await _firestore.collection(_collection).doc(bookingId).get();
        final booking = BookingModel.fromJson(bookingDoc.data()!, bookingId);
        
        String title;
        String type;
        
        if (status == 'checked_in') {
          title = "✅ Khách đã đến";
          type = "booking_checked_in";
        } else { // completed
          title = "🎉 Đơn đã hoàn thành";
          type = "booking_completed";
        }
        
        await _sendNotificationToShop(
          shopId: booking.shopId,
          title: title,
          body: "${booking.customerName} - ${booking.serviceName}",
          type: type,
          relatedBookingId: bookingId,
        );
      }
    } catch (e) {
      print("--> Lỗi cập nhật status: $e");
      rethrow;
    }
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

  Stream<List<BookingModel>> getBookingsByCustomer(String shopId, String phone) {
    return _firestore
        .collection(_collection)
        .where('shop_id', isEqualTo: shopId)
        .where('customer_phone', isEqualTo: phone)
        .orderBy('start_time', descending: true) // Đơn mới nhất lên đầu
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Kiểm tra xem service có đang được sử dụng trong booking không
  Future<int> countBookingsByService(String shopId, String serviceId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('shop_id', isEqualTo: shopId)
          .where('service_id', isEqualTo: serviceId)
          .where('status', whereIn: ['confirmed', 'checked_in']) // Chỉ đếm booking chưa hoàn thành
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      print("--> Lỗi đếm booking theo service: $e");
      return 0;
    }
  }

  // Xóa tất cả booking của một service
  Future<int> deleteBookingsByService(String shopId, String serviceId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('shop_id', isEqualTo: shopId)
          .where('service_id', isEqualTo: serviceId)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      return snapshot.docs.length;
    } catch (e) {
      print("--> Lỗi xóa booking theo service: $e");
      return 0;
    }
  }

  Future<BookingModel?> getBookingById(String id) async {
    try {
      final doc = await _firestore.collection('bookings').doc(id).get();
      if (doc.exists) {
        return BookingModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print("Lỗi lấy booking: $e");
      return null;
    }
  }

  // 📝 Gửi notification đến shop (qua Supabase Edge Function)
  Future<void> _sendNotificationToShop({
    required String shopId,
    required String title,
    required String body,
    required String type,
    String? relatedBookingId,
  }) async {
    try {
      // 1. Lưu vào Firestore (để có lịch sử)
      final notification = NotificationModel(
        shopId: shopId,
        title: title,
        body: body,
        type: type,
        relatedBookingId: relatedBookingId,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toJson());
      print("--> Notification lưu vào Firestore thành công");

      // 2. Gọi Supabase Edge Function để gửi FCM
      final response = await _supabase.functions.invoke(
        'send-notification',
        body: {
          'shopId': shopId,
          'title': title,
          'body': body,
          'type': type,
          'relatedBookingId': relatedBookingId,
        },
      );

      if (response.status == 200) {
        print("--> Edge Function gửi FCM thành công");
      } else {
        print("--> Edge Function lỗi: ${response.data}");
      }
    } catch (e) {
      print("--> Lỗi gửi notification: $e");
      // Không throw error để app vẫn hoạt động nếu notification fail
    }
  }
}
