INSERT INTO public.roles(name, description)
VALUES
  ('admin', 'System administrator'),
  ('reviewer', 'Approver/reviewer'),
  ('vendor', 'Vendor user')
ON CONFLICT (name) DO NOTHING
