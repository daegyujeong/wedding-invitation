-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create templates table
CREATE TABLE templates (
    id TEXT PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    thumbnail TEXT,
    primary_color INTEGER,
    default_settings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create invitations table
CREATE TABLE invitations (
    id TEXT PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_id TEXT NOT NULL REFERENCES templates(id),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    groom_name TEXT NOT NULL,
    bride_name TEXT NOT NULL,
    wedding_date DATE NOT NULL,
    wedding_time TEXT NOT NULL,
    venue TEXT NOT NULL,
    address TEXT NOT NULL,
    groom_father TEXT,
    groom_mother TEXT,
    bride_father TEXT,
    bride_mother TEXT,
    greeting TEXT,
    cover_image TEXT,
    gallery_images TEXT[] DEFAULT '{}',
    style_settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create messages table
CREATE TABLE messages (
    id TEXT PRIMARY KEY DEFAULT uuid_generate_v4(),
    invitation_id TEXT NOT NULL REFERENCES invitations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    message TEXT NOT NULL,
    likes INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create indexes
CREATE INDEX idx_invitations_user_id ON invitations(user_id);
CREATE INDEX idx_invitations_template_id ON invitations(template_id);
CREATE INDEX idx_messages_invitation_id ON messages(invitation_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- Create RLS policies
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;

-- Templates are readable by everyone
CREATE POLICY "Templates are viewable by everyone"
    ON templates FOR SELECT
    USING (true);

-- Users can CRUD their own invitations
CREATE POLICY "Users can create their own invitations"
    ON invitations FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own invitations"
    ON invitations FOR SELECT
    USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update their own invitations"
    ON invitations FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own invitations"
    ON invitations FOR DELETE
    USING (auth.uid() = user_id);

-- Anyone can read messages for any invitation
CREATE POLICY "Messages are viewable by everyone"
    ON messages FOR SELECT
    USING (true);

-- Anyone can create messages
CREATE POLICY "Anyone can create messages"
    ON messages FOR INSERT
    WITH CHECK (true);

-- Function to increment message likes
CREATE OR REPLACE FUNCTION increment_message_likes(message_id TEXT)
RETURNS void AS $$
BEGIN
    UPDATE messages
    SET likes = likes + 1
    WHERE id = message_id;
END;
$$ LANGUAGE plpgsql;

-- Insert default templates
INSERT INTO templates (id, name, description, thumbnail, primary_color, default_settings) VALUES
('classic', '클래식', '전통적이고 우아한 디자인', 'https://via.placeholder.com/300x400/FFE4E1/FF69B4?text=Classic', 4294941409, '{"fontFamily": "serif"}'),
('modern', '모던', '심플하고 세련된 디자인', 'https://via.placeholder.com/300x400/E6E6FA/9370DB?text=Modern', 4293322490, '{"fontFamily": "sans-serif"}'),
('romantic', '로맨틱', '사랑스럽고 따뜻한 디자인', 'https://via.placeholder.com/300x400/FFF0F5/FF1493?text=Romantic', 4294967285, '{"fontFamily": "cursive"}'),
('nature', '내추럴', '자연친화적인 디자인', 'https://via.placeholder.com/300x400/F0FFF0/228B22?text=Nature', 4294713584, '{"fontFamily": "sans-serif"}'),
('minimal', '미니멀', '간결하고 깔끔한 디자인', 'https://via.placeholder.com/300x400/F5F5F5/696969?text=Minimal', 4294309365, '{"fontFamily": "sans-serif"}'),
('luxury', '럭셔리', '고급스럽고 화려한 디자인', 'https://via.placeholder.com/300x400/FFFAF0/FFD700?text=Luxury', 4294966000, '{"fontFamily": "serif"}');
