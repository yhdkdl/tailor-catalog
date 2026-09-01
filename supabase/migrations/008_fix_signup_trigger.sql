-- Fix handle_new_tailor_signup to explicitly qualify public.tailors and set search_path
create or replace function public.handle_new_tailor_signup()
returns trigger
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
  raw_slug text;
  final_slug text;
  counter integer := 0;
begin
  raw_slug := lower(regexp_replace(regexp_replace(
    coalesce(new.raw_user_meta_data->>'shop_name', 'shop'),
    '[^a-zA-Z0-9\s]', '', 'g'
  ), '\s+', '-', 'g'));

  if raw_slug = '' then
    raw_slug := 'tailor';
  end if;

  final_slug := raw_slug;
  while exists (select 1 from public.tailors where shop_slug = final_slug) loop
    counter := counter + 1;
    final_slug := raw_slug || '-' || counter;
  end loop;

  insert into public.tailors (auth_id, shop_name, shop_slug, email, phone, status)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'shop_name', 'Tailor Shop'),
    final_slug,
    new.email,
    new.raw_user_meta_data->>'phone',
    'pending'
  )
  on conflict (auth_id) do update
  set
    shop_name = excluded.shop_name,
    email = excluded.email,
    phone = excluded.phone;

  return new;
end;
$$;

-- Ensure trigger is bound properly
drop trigger if exists on_tailor_signup on auth.users;
create trigger on_tailor_signup
  after insert on auth.users
  for each row
  when (new.raw_user_meta_data->>'role' = 'tailor')
  execute function public.handle_new_tailor_signup();
