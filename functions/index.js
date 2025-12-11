/* eslint-disable */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// 🎯 TRIGGER: Khi có booking mới, gửi notification tới tất cả thiết bị của shop này
exports.notifyNewBooking = functions.firestore
  .document("bookings/{bookingId}")
  .onCreate(async (snap, context) => {
    const booking = snap.data();
    const shopId = booking.shop_id;
    const bookingId = context.params.bookingId;

    try {
      // 1. Format dữ liệu thông báo
      const startTime = booking.start_time.toDate().toLocaleTimeString("vi-VN", {
        hour: "2-digit",
        minute: "2-digit",
      });

      const notificationMessage = {
        notification: {
          title: "📅 Có khách mới đặt lịch!",
          body: `${booking.customer_name} - ${booking.service_name} lúc ${startTime}`,
          sound: "default",
        },
        data: {
          type: "new_booking",
          related_booking_id: bookingId,
          shop_id: shopId,
        },
        webpush: {
          fcmOptions: { link: "/" }
        }
      };

      // 2. Gửi qua Topic (tất cả thiết bị subscribe topic này)
      await admin.messaging().send({
        ...notificationMessage,
        topic: `shop_${shopId}_notifications`,
      });

      console.log(`✅ Gửi notification booking mới qua topic: shop_${shopId}_notifications`);

      // 3. Lưu vào collection 'notifications' (để lịch sử)
      await admin.firestore().collection('notifications').add({
        shop_id: shopId,
        title: notificationMessage.notification.title,
        body: notificationMessage.notification.body,
        type: "new_booking",
        related_booking_id: bookingId,
        is_read: false,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`✅ Lưu notification vào Firestore collection`);

    } catch (error) {
      console.error(`❌ Lỗi gửi notification booking mới: ${error}`);
    }
  });

// 🎯 TRIGGER: Khi booking bị hủy, thông báo
exports.notifyCancelBooking = functions.firestore
  .document("bookings/{bookingId}")
  .onUpdate(async (change, context) => {
    const oldData = change.before.data();
    const newData = change.after.data();

    // Chỉ xử lý nếu status thay đổi từ "confirmed" → "cancelled"
    if (oldData.status !== "confirmed" || newData.status !== "cancelled") {
      return null;
    }

    const shopId = newData.shop_id;
    const bookingId = context.params.bookingId;

    try {
      const notificationMessage = {
        notification: {
          title: "❌ Đơn hàng bị hủy",
          body: `Đơn của ${newData.customer_name} - ${newData.service_name} đã bị hủy`,
          sound: "default",
        },
        data: {
          type: "booking_cancelled",
          related_booking_id: bookingId,
          shop_id: shopId,
        },
        webpush: {
          fcmOptions: { link: "/" }
        }
      };

      // Gửi qua Topic
      await admin.messaging().send({
        ...notificationMessage,
        topic: `shop_${shopId}_notifications`,
      });

      console.log(`✅ Gửi notification hủy booking qua topic: shop_${shopId}_notifications`);

      // Lưu vào collection
      await admin.firestore().collection('notifications').add({
        shop_id: shopId,
        title: notificationMessage.notification.title,
        body: notificationMessage.notification.body,
        type: "booking_cancelled",
        related_booking_id: bookingId,
        is_read: false,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });

    } catch (error) {
      console.error(`❌ Lỗi gửi notification hủy booking: ${error}`);
    }

    return null;
  });

exports.remind15MinutesBefore = functions
  .pubsub
  .schedule("every 1 minutes")
  .timeZone("Asia/Ho_Chi_Minh")
  .onRun(async () => {
    const now = new Date();
    const in15Minutes = new Date(now.getTime() + 15 * 60 * 1000);

    const snapshot = await admin
      .firestore()
      .collection("bookings")
      .where("start_time", ">", admin.firestore.Timestamp.fromDate(now))
      .where("start_time", "<=", admin.firestore.Timestamp.fromDate(in15Minutes))
      .in("status", ["confirmed", "checked_in", "completed"]) // bạn có status "completed" nữa
      .get();

    if (snapshot.empty) return null;

    const promises = [];

    for (const doc of snapshot.docs) {
      const booking = doc.data();
      if (booking.reminded_15min === true) continue;

      const timeStr = booking.start_time.toDate().toLocaleTimeString("vi-VN", {
        hour: "2-digit",
        minute: "2-digit",
      });

      const payload = {
        notification: {
          title: "Sắp có khách rồi nè!",
          body: `${booking.customer_name} • ${booking.service_name || "Dịch vụ"} • ${timeStr}`,
          sound: "default",
        },
      };

      // Gửi cho tất cả token trong shop_tokens (nếu có)
      const tokensSnap = await admin.firestore().collection("shop_tokens").get();
      tokensSnap.docs.forEach((t) => {
        if (t.data().token) {
          promises.push(admin.messaging().sendToDevice(t.data().token, payload));
        }
      });

      // Đánh dấu đã nhắc
      promises.push(doc.ref.update({ reminded_15min: true }));
    }

    await Promise.all(promises);
    return null;
  });