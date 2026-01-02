# Hướng dẫn Deploy Edge Function gửi OTP Email

## 1. Đăng ký Resend API (Miễn phí)

1. Truy cập: https://resend.com/
2. Đăng ký tài khoản (Free tier: 3,000 emails/tháng)
3. Vào **API Keys** → Create API Key
4. Copy API Key (dạng `re_...`)

## 2. Setup Supabase Secrets

```bash
# Login Supabase (nếu chưa)
npx supabase login

# Link project (nếu chưa)
npx supabase link --project-ref <YOUR_PROJECT_REF>

# Set Resend API Key
npx supabase secrets set RESEND_API_KEY=re_xxxxxxxxxxxxx
```

## 3. Deploy Edge Function

```bash
cd d:/Projects/note_calendar

# Deploy function
npx supabase functions deploy send-verification-otp
```

## 4. Test Function

```bash
# Test local
npx supabase functions serve send-verification-otp --env-file ./supabase/.env

# Invoke test
curl -i --location --request POST 'http://localhost:54321/functions/v1/send-verification-otp' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"email":"test@example.com","fullName":"Nguyễn Văn A","otpCode":"123456"}'
```

## 5. Verify trong App

1. Đăng ký tài khoản mới
2. Kiểm tra email (inbox hoặc spam)
3. Nhập mã OTP 6 số
4. Nhấn "Xác thực"

## 6. Custom Domain Email (Tùy chọn)

Để email không bị spam và có branding tốt hơn:

1. Vào **Resend Dashboard** → **Domains**
2. Add domain của bạn (VD: `notecalendar.com`)
3. Verify DNS records (SPF, DKIM, DMARC)
4. Đổi sender trong `index.ts`:
   ```typescript
   from: 'Note Calendar <no-reply@notecalendar.com>'
   ```

## Lưu ý

- Email template trong file: `supabase/functions/send-verification-otp/index.ts`
- Có thể tùy chỉnh màu sắc, logo, nội dung
- OTP hết hạn sau 10 phút
- Free tier Resend: 3,000 emails/tháng, đủ cho development
