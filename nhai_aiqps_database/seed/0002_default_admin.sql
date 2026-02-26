INSERT INTO public.users(user_type, email, full_name, organization_name, password_hash, is_active, is_email_verified)
VALUES ('admin', 'admin@example.com', 'Default Admin', 'NHAI', '$2b$12$REPLACE_WITH_REAL_HASH_IN_BACKEND', true, false)
ON CONFLICT (email) DO NOTHING
