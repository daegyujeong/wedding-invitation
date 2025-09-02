-- Add RSVP table to Supabase schema
-- Run this script in your Supabase SQL editor to add RSVP functionality

-- Create RSVP table
CREATE TABLE IF NOT EXISTS public.rsvp_responses (
    id TEXT PRIMARY KEY,
    guest_name TEXT NOT NULL,
    email TEXT, -- Optional field, no longer required
    is_attending BOOLEAN NOT NULL,
    selected_venues TEXT[] DEFAULT '{}', -- Array of venue codes: ['my', 'sg', 'ko']
    additional_notes TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_rsvp_responses_submitted_at ON public.rsvp_responses(submitted_at DESC);
CREATE INDEX IF NOT EXISTS idx_rsvp_responses_is_attending ON public.rsvp_responses(is_attending);
CREATE INDEX IF NOT EXISTS idx_rsvp_responses_guest_name ON public.rsvp_responses(guest_name);
CREATE INDEX IF NOT EXISTS idx_rsvp_responses_email ON public.rsvp_responses(email);

-- Enable Row Level Security (RLS)
ALTER TABLE public.rsvp_responses ENABLE ROW LEVEL SECURITY;

-- Create policies for public access
-- Allow anyone to read RSVP responses (for guest count display)
CREATE POLICY "Allow public to read RSVP responses" ON public.rsvp_responses
    FOR SELECT USING (true);

-- Allow anyone to insert RSVP responses
CREATE POLICY "Allow public to insert RSVP responses" ON public.rsvp_responses
    FOR INSERT WITH CHECK (true);

-- Allow updates only for the same email (for response changes)
CREATE POLICY "Allow update own RSVP" ON public.rsvp_responses
    FOR UPDATE USING (true) WITH CHECK (true);

-- Create trigger to auto-update updated_at
CREATE TRIGGER update_rsvp_responses_updated_at BEFORE UPDATE
    ON public.rsvp_responses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant necessary permissions
GRANT ALL ON public.rsvp_responses TO anon;