DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_type') THEN
    CREATE TYPE public.user_type AS ENUM ('vendor','admin','reviewer','system');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'mfa_method') THEN
    CREATE TYPE public.mfa_method AS ENUM ('totp','sms','email','webauthn');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'doc_kind') THEN
    CREATE TYPE public.doc_kind AS ENUM ('rfp','corrigendum','addendum','sbd','policy','vendor_upload','generated_reply','other');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'doc_status') THEN
    CREATE TYPE public.doc_status AS ENUM ('uploaded','processing','processed','failed','archived');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'conversation_status') THEN
    CREATE TYPE public.conversation_status AS ENUM ('active','closed','archived');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'message_role') THEN
    CREATE TYPE public.message_role AS ENUM ('user','assistant','system','tool');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'workflow_status') THEN
    CREATE TYPE public.workflow_status AS ENUM ('draft','in_review','approved','rejected','cancelled');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'approval_status') THEN
    CREATE TYPE public.approval_status AS ENUM ('pending','approved','rejected','needs_changes','skipped');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'audit_action') THEN
    CREATE TYPE public.audit_action AS ENUM ('create','update','delete','login','logout','mfa_enable','mfa_disable','upload','download','approve','reject','view','export');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'usage_event_type') THEN
    CREATE TYPE public.usage_event_type AS ENUM ('api_call','llm_tokens','document_ingest','speech_to_text','webex_meeting','email_notification','storage');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'billing_invoice_status') THEN
    CREATE TYPE public.billing_invoice_status AS ENUM ('draft','issued','paid','void','overdue');
  END IF;
END$$
