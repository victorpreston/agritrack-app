SELECT
    auth.users.id AS user_id,
    auth.users.email,
    user_profiles.phone,
    user_profiles.subscription,
    farms.name AS farm_name
FROM auth.users
LEFT JOIN user_profiles ON auth.users.id = user_profiles.id
LEFT JOIN farms ON user_profiles.id = farms.owner_id;