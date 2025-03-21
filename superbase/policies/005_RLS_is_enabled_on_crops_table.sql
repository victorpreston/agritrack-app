-- 1. RLS is enabled on crops table
ALTER TABLE crops ENABLE ROW LEVEL SECURITY;

-- 2. Allow authenticated users to read crops (SELECT)
CREATE POLICY "Allow read access to crops for authenticated users"
ON crops
FOR SELECT
TO authenticated
USING (
  auth.uid() IS NOT NULL
);