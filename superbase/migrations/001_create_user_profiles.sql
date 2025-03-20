CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    profile_picture TEXT DEFAULT '',
    member_since TIMESTAMP DEFAULT now(),
    subscription TEXT DEFAULT 'Free'
);

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;