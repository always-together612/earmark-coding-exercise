BEGIN;

SELECT plan( 3 );

SELECT policies_are(
  'public',
  'courses_likes',
  ARRAY [
    'select_own_liked_courses'
  ]
);


SELECT gen_random_uuid() AS user1_id \gset
SELECT gen_random_uuid() AS user1_auth_id \gset
SELECT gen_random_uuid() AS user2_id \gset
SELECT gen_random_uuid() AS user2_auth_id \gset
SELECT gen_random_uuid() AS course1_id \gset
SELECT gen_random_uuid() AS course2_id \gset


-- Insert two auth users
INSERT INTO auth.users (id) VALUES (:'user1_auth_id');
INSERT INTO auth.users (id) VALUES (:'user2_auth_id');


-- Delete existing public users before insert
DELETE FROM public.users;

-- Insert two users with auth_user_id
INSERT INTO public.users (id, auth_user_id, first_name, last_name, created_at, updated_at) 
VALUES
    (:'user1_id', :'user1_auth_id', 'User', 'One', now(), now()),
    (:'user2_id', :'user2_auth_id', 'User', 'Two', now(), now());


-- Insert two courses
INSERT INTO public.courses (id, title, active, cost, created_at, updated_at) 
VALUES
    (:'course1_id', 'Course One', true, 99.99, now(), now()),
    (:'course2_id', 'Course Two', true, 49.99, now(), now());


-- Insert course likes with random UUIDs
INSERT INTO public.courses_likes (user_id, course_id, created_at, updated_at) 
VALUES
    (:'user1_id', :'course1_id', now(), now()),
    (:'user2_id', :'course2_id', now(), now());

-- Set initial role and JWT claim for User 1
SET LOCAL request.jwt.claim.sub = :'user1_auth_id';
SET ROLE authenticated;

-- Test: User 1 should see only his own likes
SELECT results_eq(
  'SELECT user_id::text, course_id::text FROM public.courses_likes',
  format('VALUES (%L, %L)', :'user1_id', :'course1_id'),
  'User 1 should see only his own likes'
);


-- Test: User 2 should see only his own likes
SET LOCAL request.jwt.claim.sub = :'user2_auth_id';
set role authenticated;

select results_eq(
  'SELECT user_id::text, course_id::text FROM public.courses_likes',
  format('VALUES (%L, %L)', :'user2_id', :'course2_id'),
  'User 2 should see only his own likes'
);


SELECT * FROM finish();
ROLLBACK;