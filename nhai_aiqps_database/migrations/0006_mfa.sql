CREATE TABLE IF NOT EXISTS public.mfa_devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  method public.mfa_method NOT NULL,
  label TEXT,
  secret_encrypted TEXT, -- store encrypted secret (app-level encryption key management)
  is_enabled BOOLEAN NOT NULL DEFAULT true,
  last_used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, method, label)
)
