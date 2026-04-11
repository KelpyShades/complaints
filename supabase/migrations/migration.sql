-- ============================================================
-- Complaints Management System — Supabase Migration
-- ============================================================
-- Run this in the Supabase SQL Editor to create all tables.
--
-- Dependency order:
--   1. Tables: profiles → complaints → comments
--   2. RLS + trigger
--   3. Realtime & indexes
--
-- Roles: 'user' (student, default) and 'admin' (set manually)
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 1. CREATE TABLES
-- ─────────────────────────────────────────────────────────────

-- 1a. Profiles (extends auth.users)
create table if not exists public.profiles (
  id            uuid        references auth.users(id) on delete cascade primary key,
  full_name     text        not null,
  email         text        not null,
  role          text        not null default 'user',
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);


-- 1b. Complaints
create table if not exists public.complaints (
  id            uuid        primary key default gen_random_uuid(),
  title         text        not null,
  description   text        not null,
  category      text        not null,
  status        text        not null default 'pending',
  user_id       uuid        references public.profiles(id) not null,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);


-- 1c. Complaint Comments
create table if not exists public.complaint_comments (
  id            uuid        primary key default gen_random_uuid(),
  complaint_id  uuid        references public.complaints(id) on delete cascade not null,
  user_id       uuid        references public.profiles(id) not null,
  content       text        not null,
  created_at    timestamptz default now()
);


-- ─────────────────────────────────────────────────────────────
-- 2. ENABLE ROW LEVEL SECURITY
-- ─────────────────────────────────────────────────────────────

alter table public.profiles          enable row level security;
alter table public.complaints        enable row level security;
alter table public.complaint_comments enable row level security;


-- ─────────────────────────────────────────────────────────────
-- 3. TRIGGER — Auto-create profile on signup
-- ─────────────────────────────────────────────────────────────

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    coalesce(new.email, '')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- ─────────────────────────────────────────────────────────────
-- 4. RLS POLICIES — Profiles
-- ─────────────────────────────────────────────────────────────

create policy "Profiles are viewable by authenticated users"
  on public.profiles for select
  to authenticated
  using (true);

create policy "Users can insert own profile"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id);


-- ─────────────────────────────────────────────────────────────
-- 5. RLS POLICIES — Complaints
-- ─────────────────────────────────────────────────────────────

-- Students see only their own; admins see all
create policy "Complaints are viewable by owner or admin"
  on public.complaints for select
  to authenticated
  using (
    auth.uid() = user_id
    or exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role = 'admin'
    )
  );

-- Only students (role='user') create complaints
create policy "Students can create own complaints"
  on public.complaints for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Students can update own pending; admins can update any
create policy "Owner or admin can update complaints"
  on public.complaints for update
  to authenticated
  using (
    auth.uid() = user_id
    or exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role = 'admin'
    )
  );

-- Students can delete own pending complaints
create policy "Students can delete own pending complaints"
  on public.complaints for delete
  to authenticated
  using (auth.uid() = user_id and status = 'pending');


-- ─────────────────────────────────────────────────────────────
-- 6. RLS POLICIES — Comments
-- ─────────────────────────────────────────────────────────────

create policy "Comments are viewable by authenticated users"
  on public.complaint_comments for select
  to authenticated
  using (true);

create policy "Authenticated users can add comments"
  on public.complaint_comments for insert
  to authenticated
  with check (auth.uid() = user_id);


-- ─────────────────────────────────────────────────────────────
-- 7. REALTIME
-- ─────────────────────────────────────────────────────────────

alter publication supabase_realtime add table public.complaints;
alter publication supabase_realtime add table public.complaint_comments;
alter publication supabase_realtime add table public.profiles;


-- ─────────────────────────────────────────────────────────────
-- 8. INDEXES
-- ─────────────────────────────────────────────────────────────

create index if not exists idx_complaints_user_id    on public.complaints(user_id);
create index if not exists idx_complaints_status     on public.complaints(status);
create index if not exists idx_comments_complaint_id on public.complaint_comments(complaint_id);
