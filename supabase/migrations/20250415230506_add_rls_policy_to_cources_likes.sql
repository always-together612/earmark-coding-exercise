-- Enable Row Level Security on the table
ALTER TABLE public.courses_likes ENABLE ROW LEVEL SECURITY;



-- Function to check if the authenticated user owns the record with the given user_id
CREATE OR REPLACE FUNCTION public.user_owns_record(user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
STABLE
SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.users 
        WHERE id = user_id 
        AND auth_user_id = auth.uid()
        LIMIT 1
    );
END;
$function$;

-- Create a policy allowing users to select only their own liked courses
CREATE POLICY select_own_liked_courses
ON public.courses_likes
FOR SELECT
TO public
USING (user_owns_record(user_id));


-- Add updated_at column to courses_likes table if missing
ALTER TABLE public.courses_likes
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT now();


