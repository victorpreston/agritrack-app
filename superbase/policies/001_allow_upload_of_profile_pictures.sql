CREATE POLICY "Allow upload of profile pictures"
ON "storage"."objects"
AS PERMISSIVE FOR INSERT
TO authenticated
WITH CHECK (auth.uid() IS NOT NULL);