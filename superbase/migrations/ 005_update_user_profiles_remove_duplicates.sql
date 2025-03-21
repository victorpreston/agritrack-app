-- Step 1: Drop foreign key constraint in farms table
ALTER TABLE farms DROP CONSTRAINT farms_owner_id_fkey;

-- Step 2: Drop primary key constraint in user_profiles
ALTER TABLE user_profiles DROP CONSTRAINT user_profiles_pkey;

-- Step 3: Modify user_profiles.id to reference auth.users(id)
ALTER TABLE user_profiles ALTER COLUMN id SET DEFAULT auth.uid();
ALTER TABLE user_profiles ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);

-- Step 4: Recreate foreign key constraint in farms table
ALTER TABLE farms ADD CONSTRAINT farms_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES user_profiles(id) ON DELETE CASCADE;