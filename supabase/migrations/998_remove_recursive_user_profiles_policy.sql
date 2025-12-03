-- Remove the recursive policy that causes infinite recursion
-- This policy tries to query user_profiles from within user_profiles
DROP POLICY IF EXISTS "Users can view company profiles" ON public.user_profiles;

-- The "user_profiles_select" policy with "true" already allows viewing all profiles
-- So we don't need this recursive one
