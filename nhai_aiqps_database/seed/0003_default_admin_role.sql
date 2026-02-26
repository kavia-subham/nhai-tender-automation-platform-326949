INSERT INTO public.user_roles(user_id, role_id)
SELECT u.id, r.id
FROM public.users u
JOIN public.roles r ON r.name='admin'
WHERE u.email='admin@example.com'
ON CONFLICT (user_id, role_id) DO NOTHING
