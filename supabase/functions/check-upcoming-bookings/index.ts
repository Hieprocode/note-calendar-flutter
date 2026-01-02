// Edge Function: Kiểm tra lịch hẹn sắp tới và gửi reminder
// Chạy mỗi phút qua Supabase Cron Job

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Function to get OAuth 2.0 access token from service account
async function getAccessToken(serviceAccount: any): Promise<string> {
  const jwtHeader = btoa(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  
  const now = Math.floor(Date.now() / 1000);
  const jwtClaimSet = {
    iss: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging https://www.googleapis.com/auth/datastore',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  };
  const jwtClaimSetEncoded = btoa(JSON.stringify(jwtClaimSet)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
  
  const signatureInput = `${jwtHeader}.${jwtClaimSetEncoded}`;
  
  const privateKey = await crypto.subtle.importKey(
    'pkcs8',
    pemToBinary(serviceAccount.private_key),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  );
  
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    privateKey,
    new TextEncoder().encode(signatureInput)
  );
  
  const signatureBase64 = btoa(String.fromCharCode(...new Uint8Array(signature))).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
  const jwt = `${signatureInput}.${signatureBase64}`;
  
  const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });
  
  const tokenData = await tokenResponse.json();
  
  if (!tokenData.access_token) {
    throw new Error(`Failed to get access token: ${JSON.stringify(tokenData)}`);
  }
  
  return tokenData.access_token;
}

function pemToBinary(pem: string): ArrayBuffer {
  const pemContents = pem
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s/g, '');
  const binaryString = atob(pemContents);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;
}

// Query Firestore via REST API
async function queryUpcomingBookings(accessToken: string, projectId: string) {
  const now = new Date();
  const start15min = new Date(now.getTime() + 14 * 60 * 1000); // 14 phút nữa
  const end15min = new Date(now.getTime() + 16 * 60 * 1000);   // 16 phút nữa
  
  const query = {
    structuredQuery: {
      from: [{ collectionId: 'bookings' }],
      where: {
        compositeFilter: {
          op: 'AND',
          filters: [
            {
              fieldFilter: {
                field: { fieldPath: 'start_time' },
                op: 'GREATER_THAN_OR_EQUAL',
                value: { timestampValue: start15min.toISOString() }
              }
            },
            {
              fieldFilter: {
                field: { fieldPath: 'start_time' },
                op: 'LESS_THAN',
                value: { timestampValue: end15min.toISOString() }
              }
            },
            {
              fieldFilter: {
                field: { fieldPath: 'status' },
                op: 'NOT_EQUAL',
                value: { stringValue: 'cancelled' }
              }
            }
          ]
        }
      }
    }
  };
  
  const response = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents:runQuery`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(query),
    }
  );
  
  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Firestore query failed: ${error}`);
  }
  
  const results = await response.json();
  return results;
}

// Send FCM notification
async function sendFCMNotification(
  accessToken: string,
  projectId: string,
  shopId: string,
  customerName: string,
  bookingTime: string
) {
  const topic = `shop_${shopId}_notifications`;
  
  const fcmPayload = {
    message: {
      topic: topic,
      notification: {
        title: '⏰ Sắp có khách',
        body: `${customerName} - Lịch hẹn lúc ${bookingTime}`,
      },
      data: {
        type: 'booking_reminder',
        shop_id: shopId,
      },
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
          },
        },
      },
    },
  };
  
  const fcmResponse = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`,
      },
      body: JSON.stringify(fcmPayload),
    }
  );
  
  if (!fcmResponse.ok) {
    const error = await fcmResponse.json();
    console.error('FCM Error:', error);
    throw new Error(`FCM failed: ${JSON.stringify(error)}`);
  }
  
  return await fcmResponse.json();
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    console.log('🔍 Checking for upcoming bookings...');
    
    const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
    if (!serviceAccountJson) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT not configured');
    }

    const serviceAccount = JSON.parse(serviceAccountJson);
    const projectId = serviceAccount.project_id;
    
    // Get access token
    const accessToken = await getAccessToken(serviceAccount);
    
    // Query upcoming bookings
    const results = await queryUpcomingBookings(accessToken, projectId);
    
    let sentCount = 0;
    
    // Process each booking
    for (const result of results) {
      if (!result.document) continue;
      
      const fields = result.document.fields;
      const shopId = fields.shop_id?.stringValue;
      const customerName = fields.customer_name?.stringValue;
      const startTime = fields.start_time?.timestampValue;
      
      if (!shopId || !customerName || !startTime) continue;
      
      // Format time
      const bookingDate = new Date(startTime);
      const timeStr = `${bookingDate.getHours().toString().padStart(2, '0')}:${bookingDate.getMinutes().toString().padStart(2, '0')}`;
      
      // Send notification
      try {
        await sendFCMNotification(accessToken, projectId, shopId, customerName, timeStr);
        console.log(`✅ Sent reminder for ${customerName} at ${timeStr} to shop ${shopId}`);
        sentCount++;
      } catch (error) {
        console.error(`❌ Failed to send reminder:`, error);
      }
    }
    
    return new Response(
      JSON.stringify({ 
        success: true,
        message: `Processed ${results.length} bookings, sent ${sentCount} notifications`,
        timestamp: new Date().toISOString()
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    );

  } catch (error) {
    console.error('❌ Error:', error);
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    );
  }
});
