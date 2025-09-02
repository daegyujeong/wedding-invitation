-- Supabase Database Schema for Wedding Invitation App
-- Run this script in your Supabase SQL editor to create the necessary tables

-- Create guestbook_messages table
CREATE TABLE IF NOT EXISTS public.guestbook_messages (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    message TEXT NOT NULL,
    relationship TEXT,
    is_approved BOOLEAN DEFAULT true,
    is_deleted BOOLEAN DEFAULT false,
    password TEXT, -- Store hashed password for message deletion
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_guestbook_messages_created_at ON public.guestbook_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_guestbook_messages_is_approved ON public.guestbook_messages(is_approved);
CREATE INDEX IF NOT EXISTS idx_guestbook_messages_is_deleted ON public.guestbook_messages(is_deleted);

-- Enable Row Level Security (RLS)
ALTER TABLE public.guestbook_messages ENABLE ROW LEVEL SECURITY;

-- Create policies for public access
-- Allow anyone to read approved and non-deleted messages
CREATE POLICY "Allow public to read approved messages" ON public.guestbook_messages
    FOR SELECT USING (is_approved = true AND is_deleted = false);

-- Allow anyone to insert messages (they will need moderation)
CREATE POLICY "Allow public to insert messages" ON public.guestbook_messages
    FOR INSERT WITH CHECK (true);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to auto-update updated_at
CREATE TRIGGER update_guestbook_messages_updated_at BEFORE UPDATE
    ON public.guestbook_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create admin functions for message moderation
-- These would be called by authenticated admin users

-- Function to approve a message
CREATE OR REPLACE FUNCTION approve_message(message_id TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE public.guestbook_messages
    SET is_approved = true
    WHERE id = message_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to reject a message
CREATE OR REPLACE FUNCTION reject_message(message_id TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE public.guestbook_messages
    SET is_approved = false
    WHERE id = message_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to soft delete a message with password verification
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

-- Optional: Create venues table for location data
CREATE TABLE IF NOT EXISTS public.venues (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    country TEXT,
    event_type TEXT,
    event_date TIMESTAMP WITH TIME ZONE,
    map_links JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable RLS for venues
ALTER TABLE public.venues ENABLE ROW LEVEL SECURITY;

-- Allow public read access to venues
CREATE POLICY "Allow public to read venues" ON public.venues
    FOR SELECT USING (true);

-- Create trigger for venues updated_at
CREATE TRIGGER update_venues_updated_at BEFORE UPDATE
    ON public.venues
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Optional: Create wedding_info table for general wedding information
CREATE TABLE IF NOT EXISTS public.wedding_info (
    id TEXT PRIMARY KEY DEFAULT 'main',
    bride_name TEXT,
    groom_name TEXT,
    wedding_date TIMESTAMP WITH TIME ZONE,
    ceremony_time TEXT,
    reception_time TEXT,
    ceremony_location TEXT,
    reception_location TEXT,
    photo_gallery JSONB,
    contact_info JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable RLS for wedding_info
ALTER TABLE public.wedding_info ENABLE ROW LEVEL SECURITY;

-- Allow public read access to wedding info
CREATE POLICY "Allow public to read wedding info" ON public.wedding_info
    FOR SELECT USING (true);

-- Create trigger for wedding_info updated_at
CREATE TRIGGER update_wedding_info_updated_at BEFORE UPDATE
    ON public.wedding_info
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon;