-- Seed initial test user for local development
-- This ensures there's always a user available for testing
-- Login: admin@test.com / password123

-- Create a default test user in auth.users
INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    role,
    aud,
    confirmation_token,
    recovery_token,
    email_change_token_new,
    email_change
)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000000',
    'test@example.com',
    '$2a$10$XOPbrlUPQdwdJUpSrIF6X.LbE14qsMmKGhM1A8W9iqaG1vRnNPdF2', -- bcrypt hash of "password123"
    now(),
    now(),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"first_name":"Test","last_name":"Admin"}'::jsonb,
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
)
ON CONFLICT (id) DO NOTHING;

-- Create identity record for email/password authentication
INSERT INTO auth.identities (
    id,
    user_id,
    provider_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
)
SELECT
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000001', -- provider_id (string format of user id)
    jsonb_build_object(
        'sub', '00000000-0000-0000-0000-000000000001',
        'email', 'test@example.com'
    ),
    'email',
    now(),
    now(),
    now()
WHERE NOT EXISTS (
    SELECT 1 FROM auth.identities WHERE id = '00000000-0000-0000-0000-000000000001'::uuid
);

-- Note: The user_profile will be automatically created by the trigger in 000_create_user_profiles_table.sql
-- or by the SELECT query in 011_seed_news_data.sql
