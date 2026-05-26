import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { user_id, title, body, link, type } = await req.json()

  // 1. جيب FCM token
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!)
  const { data: tokenData } = await supabase.from('user_fcm_tokens').select('fcm_token').eq('user_id', user_id).single()

  if (!tokenData?.fcm_token) return new Response('No token', { status: 400 })

  // 2. ارسل FCM
  const fcmRes = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Authorization': 'key=YOUR_SERVER_KEY',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      to: tokenData.fcm_token,
      notification: { title, body },
      data: { link, type },
      android: { priority: 'high' },
      apns: { headers: { 'apns-priority': '10' } },
    }),
  })

  // 3. خزن في notifications table
  await supabase.from('notifications').insert({
    user_id, title, body, link, type, is_read: false
  })

  return new Response('OK', { status: 200 })
})
