// Supabase Edge Function: Gửi email xác thực OTP
// Deploy: npx supabase functions deploy send-verification-otp
// Set secrets:
//   - npx supabase secrets set GMAIL_USER=your-email@gmail.com
//   - npx supabase secrets set GMAIL_APP_PASSWORD=xxxx

import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { SMTPClient } from "https://deno.land/x/denomailer@1.6.0/mod.ts"

const GMAIL_USER = Deno.env.get('GMAIL_USER') || 'tranmanhhieu2004@gmail.com'
const GMAIL_APP_PASSWORD = Deno.env.get('GMAIL_APP_PASSWORD')

interface RequestBody {
  email: string
  fullName: string
  otpCode: string
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { email, fullName, otpCode }: RequestBody = await req.json()
    
    console.log(`📧 Gửi OTP cho ${email}`)

    // HTML Email Template
    const htmlContent = `
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Xác thực Email - Note Calendar</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #f5f7fa;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f5f7fa; padding: 40px 20px;">
    <tr>
      <td align="center">
        <!-- Main Container -->
        <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 16px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); overflow: hidden;">
          
          <!-- Header with Gradient -->
          <tr>
            <td style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 20px; text-align: center;">
              <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 700;">📅 Note Calendar</h1>
              <p style="margin: 10px 0 0; color: rgba(255,255,255,0.9); font-size: 16px;">Quản lý lịch hẹn thông minh</p>
            </td>
          </tr>

          <!-- Body Content -->
          <tr>
            <td style="padding: 40px 30px;">
              <h2 style="margin: 0 0 20px; color: #1a202c; font-size: 24px; font-weight: 600;">Xin chào ${fullName}! 👋</h2>
              
              <p style="margin: 0 0 20px; color: #4a5568; font-size: 16px; line-height: 1.6;">
                Cảm ơn bạn đã đăng ký tài khoản <strong>Note Calendar</strong>. 
                Để hoàn tất quá trình đăng ký, vui lòng nhập mã xác thực bên dưới vào ứng dụng:
              </p>

              <!-- OTP Code Box -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                <tr>
                  <td align="center" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 12px; padding: 30px;">
                    <p style="margin: 0 0 10px; color: rgba(255,255,255,0.9); font-size: 14px; text-transform: uppercase; letter-spacing: 1px;">Mã xác thực của bạn</p>
                    <p style="margin: 0; color: #ffffff; font-size: 48px; font-weight: 700; letter-spacing: 8px; font-family: 'Courier New', monospace;">
                      ${otpCode}
                    </p>
                  </td>
                </tr>
              </table>

              <div style="background-color: #fff5f5; border-left: 4px solid #f56565; padding: 16px; border-radius: 8px; margin: 30px 0;">
                <p style="margin: 0; color: #742a2a; font-size: 14px; line-height: 1.6;">
                  ⚠️ <strong>Lưu ý:</strong> Mã này sẽ hết hạn sau <strong>10 phút</strong>. 
                  Vui lòng không chia sẻ mã này với bất kỳ ai.
                </p>
              </div>

              <p style="margin: 30px 0 0; color: #718096; font-size: 14px; line-height: 1.6;">
                Nếu bạn không đăng ký tài khoản này, vui lòng bỏ qua email này.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color: #f7fafc; padding: 30px; text-align: center; border-top: 1px solid #e2e8f0;">
              <p style="margin: 0 0 10px; color: #718096; font-size: 14px;">
                Gửi từ <strong>Note Calendar</strong>
              </p>
              <p style="margin: 0; color: #a0aec0; font-size: 12px;">
                © ${new Date().getFullYear()} Note Calendar. All rights reserved.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
    `.trim()

    // Gửi email qua Gmail SMTP
    const client = new SMTPClient({
      connection: {
        hostname: "smtp.gmail.com",
        port: 465,
        tls: true,
        auth: {
          username: GMAIL_USER,
          password: GMAIL_APP_PASSWORD,
        },
      },
    })

    await client.send({
      from: `Note Calendar <${GMAIL_USER}>`,
      to: email,
      subject: `🔐 Mã xác thực Note Calendar: ${otpCode}`,
      html: htmlContent,
    })

    await client.close()
    
    console.log(`✅ Email đã gửi thành công tới ${email}`)

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Email đã được gửi',
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('❌ Lỗi gửi email:', error)
    
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: (error as Error).message 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})
