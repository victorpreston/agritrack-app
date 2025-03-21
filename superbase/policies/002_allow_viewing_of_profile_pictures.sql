CREATE POLICY "Allow viewing of profile pictures"
ON "storage"."objects"
AS PERMISSIVE FOR SELECT
TO authenticated, anon
USING (true);