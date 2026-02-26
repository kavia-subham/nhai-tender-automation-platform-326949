CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_type public.user_type NOT NULL DEFAULT 'vendor',
  email CITEXT UNIQUE,
  phone TEXT,
  full_name TEXT,
  organization_name TEXT,
  password_hash TEXT, -- store bcrypt/argon2 hash; never store plaintext
  is_active BOOLEAN NOT NULL DEFAULT true,
  is_email_verified BOOLEAN NOT NULL DEFAULT false,
  is_phone_verified BOOLEAN NOT NULL DEFAULT false,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
)
