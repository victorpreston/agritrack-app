-- Enable RLS on the farms table
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;

-- Policy that allows authenticated users to insert their own farm data
CREATE POLICY "Users can insert their own farms"
ON farms
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = owner_id);

-- Policy that allows users to view and update their own farms
CREATE POLICY "Users can view and update their own farms"
ON farms
FOR SELECT USING (auth.uid() = owner_id);

-- For the crops table
ALTER TABLE crops ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert crops for their farms"
ON crops
FOR INSERT
TO authenticated
WITH CHECK (farm_id IN (
  SELECT id FROM farms WHERE owner_id = auth.uid()
));

-- For the user_profiles table
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own profiles"
ON user_profiles
FOR ALL
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);