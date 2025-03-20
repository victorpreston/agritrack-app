CREATE FUNCTION get_farm_crops(farm_id UUID)
RETURNS TABLE (
    id UUID,
    name TEXT,
    type TEXT
)
LANGUAGE sql STABLE AS $$
SELECT id, name, type
FROM crops
WHERE farm_id = get_farm_crops.farm_id;
$$;