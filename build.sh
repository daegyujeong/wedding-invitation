#!/bin/bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://otksynthwanpqpkdttzv.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90a3N5bnRod2FucHFwa2R0dHp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzE5NTIsImV4cCI6MjA3MTYwNzk1Mn0.95A7liurnMMaxcErcQIoTCjXUQypQuoJ3y25JTO9R6w \
  --web-renderer html