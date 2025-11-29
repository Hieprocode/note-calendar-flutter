/* eslint-disable */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

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