CREATE TABLE IF NOT EXISTS public.tenders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nhai_tender_id TEXT UNIQUE, -- external published identifier, if available
  title TEXT NOT NULL,
  published_at TIMESTAMPTZ,
  closing_at TIMESTAMPTZ,
  source_url TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
)
