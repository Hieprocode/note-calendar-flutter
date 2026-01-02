# Thiết kế Service & Booking

## ❓ Tại sao Booking không tự động cập nhật khi sửa Service?

### Thiết kế hiện tại (Denormalization - ĐÚNG)

Trong `BookingModel`, chúng ta lưu trữ:
```dart
String serviceId;        // ID tham chiếu
String serviceName;      // Tên dịch vụ (denormalized)
double servicePrice;     // Giá (denormalized)
int durationMinutes;     // Thời gian (denormalized)
```

### ✅ Lý do KHÔNG nên tự động cập nhật:

1. **Booking là dữ liệu lịch sử**
   - Khách đặt "Cắt tóc" giá 100k hôm qua
   - Hôm nay bạn tăng giá lên 150k
   - → Booking cũ **PHẢI** giữ nguyên 100k (không thể đổi giá booking đã đặt)

2. **Tính toàn vẹn dữ liệu**
   - Hóa đơn, báo cáo doanh thu phải khớp với giá tại thời điểm đặt
   - Không thể thay đổi lịch sử giao dịch

3. **Performance & Consistency (NoSQL Best Practice)**
   - Không cần JOIN khi query → Nhanh hơn
   - Dữ liệu đã commit không thay đổi → Tin cậy hơn

### 📊 So sánh 2 thiết kế:

| Thiết kế | Ưu điểm | Nhược điểm |
|----------|---------|------------|
| **Denormalization** (Hiện tại) | ✅ Nhanh, không cần JOIN<br>✅ Giữ nguyên lịch sử<br>✅ Best practice NoSQL | ⚠️ Service name/price trong booking cũ không tự động cập nhật (nhưng đây là MONG MUỐN) |
| **Normalization** (Lưu ID, JOIN khi query) | ✅ Luôn lấy data mới nhất | ❌ Chậm hơn (phải JOIN)<br>❌ SAI logic nghiệp vụ (giá booking thay đổi)<br>❌ Không phù hợp NoSQL |

## 🛡️ Giải pháp xóa Service an toàn

### Quy trình khi xóa Service:

1. **Kiểm tra Booking đang sử dụng**
   ```dart
   final bookingCount = await countBookingsByService(shopId, serviceId);
   ```

2. **Hiển thị cảnh báo nếu có Booking**
   - Số lượng booking đang sử dụng
   - 2 lựa chọn:
     - ❌ Hủy xóa
     - 🗑️ Xóa Service + TẤT CẢ Booking liên quan

3. **Xóa cascade (nếu user chọn)**
   ```dart
   await deleteBookingsByService(shopId, serviceId);
   await deleteService(serviceId);
   ```

### Code flow:

```dart
// services_controller.dart
Future<void> deleteService(String id, {bool forceDelete = false}) async {
  final bookingCount = await _bookingRepo.countBookingsByService(uid, id);

  if (bookingCount > 0 && !forceDelete) {
    // Hiển thị dialog cảnh báo
    _showDeleteWarningDialog(id, bookingCount);
    return;
  }

  // Xóa service (và booking nếu forceDelete = true)
  if (forceDelete && bookingCount > 0) {
    await _bookingRepo.deleteBookingsByService(uid, id);
  }
  await _serviceRepo.deleteService(id);
}
```

## 🎯 Best Practices

### ✅ Nên làm:
- Giữ denormalization cho booking (serviceName, servicePrice)
- Kiểm tra dependencies trước khi xóa
- Cảnh báo rõ ràng về cascade delete

### ❌ KHÔNG nên:
- Tự động cập nhật giá booking cũ khi sửa service
- Xóa service mà không kiểm tra booking
- JOIN nhiều collection trong NoSQL (chậm)

## 📝 Lưu ý thêm

### Nếu cần hiển thị thông tin Service mới nhất trong UI:
```dart
// Trong BookingDetailView
final currentService = await serviceRepo.getServiceById(booking.serviceId);

if (currentService != null) {
  // Hiển thị thông tin mới nhất (tham khảo)
  Text("Giá hiện tại: ${currentService.price}");
  Text("Giá khi đặt: ${booking.servicePrice}"); // Từ booking
}
```

### Audit Trail (Tùy chọn nâng cao):
Nếu cần theo dõi thay đổi, có thể thêm:
```dart
class BookingModel {
  // ... existing fields
  Map<String, dynamic>? serviceSnapshot; // Lưu toàn bộ service info tại thời điểm đặt
  DateTime? serviceLastModified;         // Thời điểm service bị sửa lần cuối
}
```

## 🚀 Tóm tắt

**Thiết kế hiện tại là ĐÚNG!**
- Booking không tự động cập nhật theo Service là **mong muốn**
- Đã thêm kiểm tra an toàn khi xóa Service
- Cascade delete được cảnh báo rõ ràng cho user
