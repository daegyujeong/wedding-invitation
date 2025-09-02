# Supabase Setup Guide for Wedding Invitation App

This guide will help you set up Supabase for the wedding invitation app with real-time features.

## Prerequisites

1. Create a Supabase account at [supabase.com](https://supabase.com)
2. Create a new Supabase project

## Step 1: Get Your Supabase Credentials

1. Go to your Supabase project dashboard
2. Navigate to Settings → API
3. Copy:
   - Project URL (looks like: `https://xxxxx.supabase.co`)
   - `anon` public key (a long JWT token)

## Step 2: Configure Environment Variables

### Option A: Using Command Line (Recommended for Development)

Run the app with environment variables:

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co \
           --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```

### Option B: Create a `.env` file (DO NOT COMMIT)

Create a `.env` file in your project root:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### Option C: Using VS Code Launch Configuration

Add to `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "wedding_invitation",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=SUPABASE_URL=https://your-project.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=your-anon-key-here"
      ]
    }
  ]
}
```

## Step 3: Create Database Tables

1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and paste the contents of `supabase_schema.sql`
4. Click "Run" to execute the SQL script

This will create:
- `guestbook_messages` table for storing guest messages
- `venues` table for location data (optional)
- `wedding_info` table for general wedding information (optional)
- Necessary indexes, policies, and triggers

## Step 4: Configure Security (Optional but Recommended)

### Enable Email Confirmation (for admin features)

1. Go to Authentication → Settings
2. Enable "Email Confirmations"
3. Configure email templates as needed

### Set Up Admin Access

1. Create an admin user in Authentication → Users
2. Use this account to moderate messages if needed

## Step 5: Test the Integration

1. Run your Flutter app with the environment variables
2. Try adding a guestbook message
3. Check the Supabase dashboard → Table Editor → guestbook_messages
4. You should see your message appear in real-time

## Features Enabled by Supabase

✅ **Real-time Updates**: Messages appear instantly across all devices
✅ **Cloud Storage**: Data persists across app reinstalls
✅ **Moderation**: Approve/reject messages before they're public
✅ **Search**: Fast full-text search across messages
✅ **Scalability**: Handles thousands of concurrent users

## Troubleshooting

### App Still Using Local Storage

The app will automatically fall back to local storage if:
- Supabase credentials are not configured
- Network connection fails
- Supabase initialization fails

Check the debug console for messages like:
- ✅ "Supabase initialized successfully"
- ⚠️ "Warning: Supabase initialization failed"

### Real-time Not Working

1. Check that Row Level Security (RLS) is enabled
2. Verify the policies allow public read access
3. Check browser console for WebSocket errors

### Messages Not Appearing

1. Verify the `is_approved` column default is `true`
2. Check RLS policies allow SELECT for approved messages
3. Look for errors in the Supabase logs

## Migration from Local Storage

To migrate existing local messages to Supabase:

1. Export messages from SharedPreferences
2. Use the Supabase dashboard or API to bulk insert
3. Verify all messages appear correctly

## Production Considerations

1. **API Keys**: Never commit API keys to version control
2. **RLS Policies**: Review and tighten security policies
3. **Backup**: Enable automatic backups in Supabase
4. **Monitoring**: Set up alerts for database usage
5. **Rate Limiting**: Configure rate limits for public endpoints

## Support

- Supabase Documentation: [docs.supabase.com](https://docs.supabase.com)
- Flutter SDK Docs: [pub.dev/packages/supabase_flutter](https://pub.dev/packages/supabase_flutter)
- Issues: Check the project's GitHub repository