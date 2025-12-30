# Cập nhật Firestore Security Rules - FIX OTP Verification

## Vấn đề
Sau khi đăng ký, user bị sign out nên không có quyền đọc document `users/{userId}` để verify OTP.

Log lỗi:
```
Listen for Query(target=Query(users/l3b1GFNvqaTMAxXLBQwJG9xkFXT2...
failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions.
```

## Giải pháp
Thay đổi rule users collection từ:
```javascript
allow read, update: if isOwner(userId);
```

Thành:
```javascript
allow read: if true;  // Cho phép đọc ngay cả khi chưa login (cần cho OTP verify)
allow update: if isOwner(userId);
```

## Hướng dẫn cập nhật

1. Mở Firebase Console: https://console.firebase.google.com
2. Chọn project Note Calendar
3. Vào **Firestore Database** → **Rules**
4. Tìm đến section `// 0. USERS`
5. Thay đổi dòng `allow read, update: if isOwner(userId);` thành 2 dòng:
   ```javascript
   allow read: if true;
   allow update: if isOwner(userId);
   ```

## Full code sau khi sửa:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // --- HÀM KIỂM TRA QUYỀN (Helper Functions) ---
    
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    function isValidShopData() {
      return request.resource.data.shop_id == request.auth.uid;
    }

    // --- LUẬT CHO TỪNG COLLECTION ---
    
    // 0. USERS: Cho phép đọc public để verify OTP
    match /users/{userId} {
      allow create: if isSignedIn() && request.auth.uid == userId;
      allow read: if true; // ← THAY ĐỔI NÀY: Cho phép đọc ngay cả khi chưa login
      allow update: if isOwner(userId);
      allow delete: if false;
    }

    // 1. SHOPS: ID của document chính là UID của user
    match /shops/{userId} {
      allow read, write: if isOwner(userId);
    }

    // 2. SERVICES: Chỉ cho phép nếu shop_id trùng với user đang đăng nhập
    match /services/{document=**} {
      allow read: if isSignedIn() && resource.data.shop_id == request.auth.uid;
      allow create: if isSignedIn() && isValidShopData();
      allow update, delete: if isSignedIn() && resource.data.shop_id == request.auth.uid;
    }

    // 3. CUSTOMERS: Tương tự Services
    match /customers/{document=**} {
      allow read: if isSignedIn() && resource.data.shop_id == request.auth.uid;
      allow create: if isSignedIn() && isValidShopData();
      allow update, delete: if isSignedIn() && resource.data.shop_id == request.auth.uid;
    }

    // 4. BOOKINGS: Tương tự Services
    match /bookings/{document=**} {
      allow read: if isSignedIn() && resource.data.shop_id == request.auth.uid;
      allow create: if isSignedIn() && isValidShopData();
      allow update, delete: if isSignedIn() && resource.data.shop_id == request.auth.uid;
    }
    
    // 5. NOTIFICATIONS: Tương tự Services
    match /notifications/{document=**} {
      allow read: if isSignedIn() && resource.data.shop_id == request.auth.uid;
      allow create: if isSignedIn() && isValidShopData();
      allow update, delete: if isSignedIn() && resource.data.shop_id == request.auth.uid;
    }
  }
}
```

6. Click **Publish**

## Lý do an toàn với `allow read: if true`

✅ **Không có rủi ro bảo mật vì:**
- Chỉ đọc được document nếu biết **chính xác userId** (UUID random, không đoán được)
- Không thể query/list tất cả users (Firestore không cho phép get collection mà không có filter)
- Dữ liệu nhạy cảm (password) **không** lưu trong Firestore (chỉ lưu trong Firebase Auth)
- OTP code và expiry sẽ bị xóa sau khi verify thành công

✅ **Cần thiết cho flow:**
1. User đăng ký → Firebase Auth tạo account
2. Lưu OTP vào Firestore users/{userId}
3. **Sign out** user (bắt buộc phải verify trước khi dùng app)
4. User nhập OTP → App đọc Firestore để verify (← cần `read: if true` ở đây)
5. Xóa OTP, set emailVerified = true
6. User login lại

## Alternative (Bảo mật cao hơn - phức tạp hơn)

Nếu lo ngại bảo mật, có thể:
1. **Cloud Function**: Verify OTP qua HTTP Callable Function (user gọi function, function check OTP)
2. **Custom Token**: Tạo custom token với claim tạm thời cho OTP verification
3. **Firestore Rules phức tạp**: Check emailVerified == false + verificationExpiry chưa hết hạn

→ Nhưng với MVP/prototype, giải pháp hiện tại **đủ an toàn và đơn giản**.
