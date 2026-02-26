CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  role public.message_role NOT NULL,
  content TEXT NOT NULL,
  tool_payload JSONB,
  token_count INT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
)
