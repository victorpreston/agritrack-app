-- Allows users to select their own crops (connected through farm ownership)
CREATE POLICY "Users can view their own crops" ON crops
  FOR SELECT
  USING (
    farm_id IN (
      SELECT id FROM farms WHERE owner_id = auth.uid()
    )
  );

-- Allows users to insert crops for their own farms
CREATE POLICY "Users can insert their own crops" ON crops
  FOR INSERT
  WITH CHECK (
    farm_id IN (
      SELECT id FROM farms WHERE owner_id = auth.uid()
    )
  );

-- Allows users to update their own crops
CREATE POLICY "Users can update their own crops" ON crops
  FOR UPDATE
  USING (
    farm_id IN (
      SELECT id FROM farms WHERE owner_id = auth.uid()
    )
  );

-- Allows users to delete their own crops
CREATE POLICY "Users can delete their own crops" ON crops
  FOR DELETE
  USING (
    farm_id IN (
      SELECT id FROM farms WHERE owner_id = auth.uid()
    )
  );