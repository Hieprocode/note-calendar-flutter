-- Setup Cron Job để check upcoming bookings mỗi phút
-- Chạy file này trong Supabase SQL Editor

-- Enable pg_cron extension (nếu chưa có)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Tạo cron job chạy mỗi phút
SELECT cron.schedule(
  'check-upcoming-bookings-reminder',  -- job name
  '* * * * *',                          -- every minute
  $$
  SELECT
    net.http_post(
      url := 'https://lyhfrrlzwrdajfdceufa.supabase.co/functions/v1/check-upcoming-bookings',
      headers := '{"Content-Type": "application/json", "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5aGZycmx6d3JkYWpmZGNldWZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI5NTQzMDEsImV4cCI6MjA0ODUzMDMwMX0.IjfvHV8tIwLhSdh4_kx-xqLNrOQVz1fPKZxMDZ0YkLQ"}'::jsonb
    ) AS request_id;
  $$
);

-- Xem danh sách cron jobs
SELECT * FROM cron.job;

-- Để xóa cron job (nếu cần)
-- SELECT cron.unschedule('check-upcoming-bookings-reminder');
