create extension if not exists "uuid-ossp";
create table tailors (
  id            uuid primary key default uuid_generate_v4(),
  auth_id       uuid unique references auth.users(id) on delete cascade,
  shop_name     text not null,
  shop_slug     text unique not null,
  status        text not null default 'pending'
                check (status in ('pending', 'approved', 'rejected')),
  phone         text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create table categories (
  id         uuid primary key default uuid_generate_v4(),
  name_en    text not null,
  name_am    text not null,
  name_om    text not null,
  name_so    text not null,
  sort_order integer not null default 0
);
create table designs (
  id            uuid primary key default uuid_generate_v4(),
  tailor_id     uuid not null references tailors(id) on delete cascade,
  category_id   uuid not null references categories(id),
  price         numeric(10, 2) not null check (price >= 0),
  tag           text,
  is_grouped    boolean not null default false,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create table design_photos (
  id             uuid primary key default uuid_generate_v4(),
  design_id      uuid not null references designs(id) on delete cascade,
  storage_path   text not null,
  order_index    integer not null default 0,
  created_at     timestamptz not null default now()
);
create index idx_designs_tailor_id on designs(tailor_id);
create index idx_designs_category_id on designs(category_id);
create index idx_design_photos_design_id on design_photos(design_id);
create index idx_tailors_shop_slug on tailors(shop_slug);
create index idx_tailors_status on tailors(status);
insert into categories (name_en, name_am, name_om, name_so, sort_order) values
  ('Women''s Dress',     'የሴቶች ልብስ',      'Uffata Dubartoota',  'Dhar Dumarku',    1),
  ('Men''s Suit',        'የወንዶች ልብስ',      'Uffata Dhiirota',    'Dhar Ragga',      2),
  ('Traditional Attire', 'ባህላዊ ልብስ',       'Uffata Aadaa',       'Dharka Dhaqanka', 3),
  ('Children''s Wear',   'የልጆች ልብስ',      'Uffata Daa''imman',  'Dhar Caruurta',   4),
  ('Casual',             'መደበኛ ልብስ',      'Uffata Guyyaa',      'Dhar Maalin',     5),
  ('Formal',             'ሥርዓታዊ ልብስ',     'Uffata Simannaa',    'Dhar Rasmiga',    6);
  create or replace function handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger tailors_updated_at
  before update on tailors
  for each row execute function handle_updated_at();

create trigger designs_updated_at
  before update on designs
  for each row execute function handle_updated_at();
  -- Enable RLS on all tables
alter table tailors enable row level security;
alter table designs enable row level security;
alter table design_photos enable row level security;
alter table categories enable row level security;

-- CATEGORIES: anyone can read, nobody can write via API
create policy "categories_public_read"
  on categories for select
  using (true);

-- TAILORS: a tailor can only read and update their own row
create policy "tailors_read_own"
  on tailors for select
  using (auth.uid() = auth_id);

create policy "tailors_update_own"
  on tailors for update
  using (auth.uid() = auth_id);

create policy "tailors_insert_own"
  on tailors for insert
  with check (auth.uid() = auth_id);

-- DESIGNS: only approved tailors can insert their own designs
create policy "designs_insert_own"
  on designs for insert
  with check (
    auth.uid() = (
      select auth_id from tailors
      where id = designs.tailor_id
      and status = 'approved'
    )
  );

create policy "designs_read_own"
  on designs for select
  using (
    auth.uid() = (
      select auth_id from tailors where id = designs.tailor_id
    )
  );

create policy "designs_update_own"
  on designs for update
  using (
    auth.uid() = (
      select auth_id from tailors where id = designs.tailor_id
    )
  );

create policy "designs_delete_own"
  on designs for delete
  using (
    auth.uid() = (
      select auth_id from tailors where id = designs.tailor_id
    )
  );

-- PUBLIC: customer catalog reads approved tailors' designs
create policy "designs_public_read"
  on designs for select
  using (
    exists (
      select 1 from tailors
      where tailors.id = designs.tailor_id
      and tailors.status = 'approved'
    )
  );

-- DESIGN PHOTOS: follow same rules as designs
create policy "photos_insert_own"
  on design_photos for insert
  with check (
    auth.uid() = (
      select t.auth_id from tailors t
      join designs d on d.tailor_id = t.id
      where d.id = design_photos.design_id
    )
  );

create policy "photos_read_own_or_public"
  on design_photos for select
  using (
    exists (
      select 1 from designs d
      join tailors t on t.id = d.tailor_id
      where d.id = design_photos.design_id
      and (t.auth_id = auth.uid() or t.status = 'approved')
    )
  );

create policy "photos_delete_own"
  on design_photos for delete
  using (
    auth.uid() = (
      select t.auth_id from tailors t
      join designs d on d.tailor_id = t.id
      where d.id = design_photos.design_id
    )
  );
  create or replace function create_tailor_profile(
  p_auth_id   uuid,
  p_shop_name text,
  p_shop_slug text,
  p_phone     text default null
)
returns tailors as $$
declare
  new_tailor tailors;
begin
  insert into tailors (auth_id, shop_name, shop_slug, phone)
  values (p_auth_id, p_shop_name, p_shop_slug, p_phone)
  returning * into new_tailor;
  return new_tailor;
end;
$$ language plpgsql security definer;