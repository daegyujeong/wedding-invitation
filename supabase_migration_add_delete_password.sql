-- Migration script to add soft delete and password features to existing guestbook_messages table
-- Run this script in your Supabase SQL editor if you already have the guestbook_messages table

-- Add is_deleted column if it doesn't exist
ALTER TABLE public.guestbook_messages 
ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false;

-- Add password column if it doesn't exist
ALTER TABLE public.guestbook_messages 
ADD COLUMN IF NOT EXISTS password TEXT;

-- Create index for is_deleted column
CREATE INDEX IF NOT EXISTS idx_guestbook_messages_is_deleted 
ON public.guestbook_messages(is_deleted);

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Allow public to read approved messages" ON public.guestbook_messages;

-- Create new policy that includes is_deleted check
CREATE POLICY "Allow public to read approved messages" ON public.guestbook_messages
    FOR SELECT USING (is_approved = true AND is_deleted = false);

-- Create or replace the soft delete function with password verification
CREATE OR REPLACE FUNCTION delete_message_with_password(message_id TEXT, user_password TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    stored_password TEXT;
BEGIN
    -- Get the stored password for the message
    SELECT password INTO stored_password
    FROM public.guestbook_messages
    WHERE id = message_id AND is_deleted = false;
    
    -- If message not found or already deleted
    IF stored_password IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Verify password (in production, this should compare hashed passwords)
    IF stored_password = user_password THEN
        UPDATE public.guestbook_messages
        SET is_deleted = true, updated_at = TIMEZONE('utc'::text, NOW())
        WHERE id = message_id;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION delete_message_with_password(TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION delete_message_with_password(TEXT, TEXT) TO authenticated;

-- Optional: Update any existing messages to have is_deleted = false (if column was just added)
UPDATE public.guestbook_messages 
SET is_deleted = false 
WHERE is_deleted IS NULL;