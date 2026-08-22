create table admin_users (
  id         uuid primary key default uuid_generate_v4(),
  auth_id    uuid unique not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- RLS: only the admin can read this table
alter table admin_users enable row level security;

create policy "admin_read_own"
  on admin_users for select
  using (auth.uid() = auth_id);
  insert into admin_users (auth_id)
values ('PASTE-YOUR-ADMIN-UUID-HERE');
create or replace function is_admin()
returns boolean as $$
begin
  return exists (
    select 1 from admin_users
    where auth_id = auth.uid()
  );
end;
$$ language plpgsql security definer;
-- Admin can read all tailors
create policy "admin_read_all_tailors"
  on tailors for select
  using (is_admin());

-- Admin can update any tailor (for approving/rejecting)
create policy "admin_update_all_tailors"
  on tailors for update
  using (is_admin());

-- Admin can read all designs
create policy "admin_read_all_designs"
  on designs for select
  using (is_admin());

-- Admin can delete any design (content moderation)
create policy "admin_delete_any_design"
  on designs for delete
  using (is_admin());

-- Admin can read all photos
create policy "admin_read_all_photos"
  on design_photos for select
  using (is_admin());
  create or replace function handle_new_tailor_signup()
returns trigger as $$
declare
  raw_slug text;
  final_slug text;
  counter integer := 0;
begin
  -- Build a URL-safe slug from the shop name
  raw_slug := lower(
    regexp_replace(
      regexp_replace(
        (new.raw_user_meta_data->>'shop_name'),
        '[^a-zA-Z0-9\s]', '', 'g'
      ),
      '\s+', '-', 'g'
    )
  );

  -- Make sure the slug is unique by appending a number if needed
  final_slug := raw_slug;
  while exists (select 1 from tailors where shop_slug = final_slug) loop
    counter := counter + 1;
    final_slug := raw_slug || '-' || counter;
  end loop;

  -- Insert the tailor profile
  insert into tailors (auth_id, shop_name, shop_slug, phone)
  values (
    new.id,
    new.raw_user_meta_data->>'shop_name',
    final_slug,
    new.raw_user_meta_data->>'phone'
  );

  return new;
end;
$$ language plpgsql security definer;

create trigger on_tailor_signup
  after insert on auth.users
  for each row
  when (new.raw_user_meta_data->>'role' = 'tailor')
  execute function handle_new_tailor_signup();