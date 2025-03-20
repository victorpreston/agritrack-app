CREATE FUNCTION get_user_profile(user_id UUID)
RETURNS TABLE (
    id UUID,
    full_name TEXT,
    email TEXT,
    phone TEXT,
    profile_picture TEXT,
    member_since TIMESTAMP,
    subscription TEXT,
    farm_id UUID
)
LANGUAGE sql STABLE AS $$
SELECT id, full_name, email, phone, profile_picture, member_since, subscription, farm_id
FROM user_profiles
WHERE id = user_id;
$$;