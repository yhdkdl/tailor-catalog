-- Keep tailor email available to the mobile auth/profile flow and admin panel.
alter table tailors add column if not exists email text;

create or replace function handle_new_tailor_signup()
returns trigger as $$
declare
  raw_slug text;
  final_slug text;
  counter integer := 0;
begin
  raw_slug := lower(regexp_replace(regexp_replace(
    (new.raw_user_meta_data->>'shop_name'), '[^a-zA-Z0-9\s]', '', 'g'
  ), '\s+', '-', 'g'));
  final_slug := raw_slug;
  while exists (select 1 from tailors where shop_slug = final_slug) loop
    counter := counter + 1;
    final_slug := raw_slug || '-' || counter;
  end loop;
  insert into tailors (auth_id, shop_name, shop_slug, email, phone)
  values (new.id, new.raw_user_meta_data->>'shop_name', final_slug, new.email, new.raw_user_meta_data->>'phone');
  return new;
end;
$$ language plpgsql security definer;