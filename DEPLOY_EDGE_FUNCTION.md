# 🚀 Deploy Supabase Edge Functions

## ✅ Đã tạo:
- ✅ Edge Function: `supabase/functions/send-notification/index.ts`
- ✅ Config: `supabase/config.toml`
- ✅ Env template: `supabase/.env.example`
- ✅ BookingRepository: Gọi Edge Function khi tạo booking

---

## 📋 Bước 1: Cài Supabase CLI

### **Windows (Scoop)**:
```bash
# Cài Scoop (nếu chưa có)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Cài Supabase CLI
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

### **Hoặc dùng NPX** (không cần cài):
```bash
npx supabase --version
```

---

## 📋 Bước 2: Login Supabase

```bash
cd d:/Projects/note_calendar

# Login (mở browser để authenticate)
npx supabase login
```

---

## 📋 Bước 3: Link Project

```bash
# List projects
npx supabase projects list

# Link project (chọn project của bạn)
npx supabase link --project-ref <your-project-ref>
```

---

## 📋 Bước 4: Setup Secrets (FCM Server Key)

### **1. Lấy Firebase Server Key:**
1. Vào Firebase Console: https://console.firebase.google.com
2. Chọn project `note-304b6`
3. Settings → Cloud Messaging
4. Copy **Server Key**

### **2. Set secret:**
```bash
npx supabase secrets set FCM_SERVER_KEY=your_server_key_here
```

---

## 📋 Bước 5: Deploy Edge Function

```bash
cd d:/Projects/note_calendar

# Deploy function
npx supabase functions deploy send-notification

# Hoặc deploy tất cả functions
npx supabase functions deploy
```

---

## 📋 Bước 6: Test Edge Function

### **Test từ terminal:**
```bash
curl -X POST https://your-project.supabase.co/functions/v1/send-notification \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "shopId": "test_shop_123",
    "title": "Test Notification",
    "body": "This is a test",
    "type": "new_booking"
  }'
```

### **Test từ Flutter app:**
Tạo booking mới → Xem console logs:
```
--> Notification lưu vào Firestore thành công
--> Edge Function gửi FCM thành công
```

---

## 🔐 Bước 7: Set Environment Variables

Tạo file `.env` (KHÔNG commit vào Git):
```bash
cd d:/Projects/note_calendar/supabase
cp .env.example .env
```

Sửa file `.env`:
```env
FCM_SERVER_KEY=AAAA...your_actual_key
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbG...
```

---

## 📊 Luồng hoạt động mới:

```
Device A: Tạo Booking
    ↓
BookingRepository.createBooking()
    ↓
_sendNotificationToShop()
    ├─ Lưu vào Firestore (lịch sử)
    └─ Gọi Supabase Edge Function
        ↓
    Edge Function: send-notification
        ↓
    Gửi FCM tới topic: "shop_{shopId}_notifications"
        ↓
    Firebase FCM Server
        ↓
    ┌─────────────────┬─────────────────┐
    ↓                 ↓
Device A          Device B
✅ Realtime       ✅ FCM Push
✅ Notification   ✅ Realtime
```

---

## ✅ Ưu điểm Supabase Edge Function:

| Tính năng | Firebase Cloud Functions | Supabase Edge Functions |
|-----------|-------------------------|------------------------|
| **Giá** | Cần Blaze Plan ($$$) | **Miễn phí** |
| **Deploy** | `firebase deploy` | `supabase functions deploy` |
| **Runtime** | Node.js | **Deno** (TypeScript native) |
| **Cold Start** | Chậm hơn | **Nhanh hơn** |
| **Logs** | Firebase Console | Supabase Dashboard |

---

## 🐛 Troubleshooting:

### **1. Function không deploy được:**
```bash
# Kiểm tra login
npx supabase projects list

# Re-login
npx supabase logout
npx supabase login
```

### **2. FCM_SERVER_KEY không hoạt động:**
```bash
# Xem secrets
npx supabase secrets list

# Update lại
npx supabase secrets set FCM_SERVER_KEY=new_key
```

### **3. Function logs:**
```bash
# Xem logs realtime
npx supabase functions logs send-notification --follow
```

---

## 📝 Notes:

- Edge Function **không cần upgrade** plan
- Mỗi lần sửa code, cần deploy lại: `npx supabase functions deploy`
- Logs xem tại: Supabase Dashboard → Edge Functions → Logs
- Nếu test local: `npx supabase functions serve send-notification`

---

**Ready to deploy! 🚀**
