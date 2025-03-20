CREATE TABLE farms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    total_area TEXT NOT NULL,
    owner_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE
);

ALTER TABLE farms ENABLE ROW LEVEL SECURITY;