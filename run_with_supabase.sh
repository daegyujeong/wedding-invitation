#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -E '^(SUPABASE_URL|SUPABASE_ANON_KEY)=' | xargs)
fi

# Run Flutter with Supabase credentials
flutter run -d chrome \
    --dart-define=SUPABASE_URL=$SUPABASE_URL \
    --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
    "$@"