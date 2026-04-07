-- ============================================
-- SLACKERS APP - SUPABASE SCHEMA
-- Run this in Supabase SQL Editor
-- ============================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ============================================
-- PROFILES TABLE
-- ============================================
create table if not exists profiles (
  id uuid references auth.users on delete cascade primary key,
  name text not null,
  gender text check (gender in ('male','female','other')) default 'other',
  currency text default 'PHP',
  lifestyle text default 'other',
  work_hours numeric default 8,
  sleep_hours numeric default 7,
  personal_hours numeric default 2,
  meals_prepped integer default 0,
  last_visit timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  -- theme
  palette text default 'sunny',
  -- diet / level up
  diet_plan text,
  -- pet system
  pet_type text default 'cat',
  pet_health integer default 80,
  pet_period text default 'daily'
);

-- Run these if you already created the table without the new columns:
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS palette text DEFAULT 'sunny';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS diet_plan text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pet_type text DEFAULT 'cat';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pet_health integer DEFAULT 80;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pet_period text DEFAULT 'daily';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS weight_kg numeric;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS target_weight_kg numeric;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS height_cm numeric;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS age integer;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS activity_level text DEFAULT '1.55';

-- ============================================
-- INGREDIENTS TABLE
-- ============================================
create table if not exists ingredients (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  key text,
  raw text not null,
  qty numeric default 1,
  unit text default 'units',
  created_at timestamptz default now()
);

-- ============================================
-- COOK LOG TABLE (daily meal tracking)
-- ============================================
create table if not exists cook_log (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  meal_name text not null,
  meal_id text not null,
  cook_mins integer not null,
  cooked_at timestamptz default now(),
  log_date date default current_date
);

-- ============================================
-- INCOME TABLE
-- ============================================
create table if not exists income (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  source text not null,
  amount numeric not null,
  freq text check (freq in ('daily','weekly','monthly','oneoff')) default 'monthly',
  created_at timestamptz default now()
);

-- ============================================
-- EXPENSES TABLE
-- ============================================
create table if not exists expenses (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  description text not null,
  amount numeric not null,
  category text default 'other',
  freq text check (freq in ('daily','weekly','monthly','oneoff')) default 'monthly',
  created_at timestamptz default now()
);

-- ============================================
-- DEBTS TABLE
-- ============================================
create table if not exists debts (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  name text not null,
  owed numeric not null,
  monthly_payment numeric default 0,
  interest_rate numeric default 0,
  created_at timestamptz default now()
);

-- ============================================
-- GOALS TABLE
-- ============================================
create table if not exists goals (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  name text not null,
  target_amount numeric not null,
  saved_amount numeric default 0,
  monthly_saving numeric default 0,
  created_at timestamptz default now()
);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- Users can only see their own data
-- ============================================

alter table profiles enable row level security;
alter table ingredients enable row level security;
alter table cook_log enable row level security;
alter table income enable row level security;
alter table expenses enable row level security;
alter table debts enable row level security;
alter table goals enable row level security;

-- Profiles policies
create policy "Users can view own profile" on profiles for select using (auth.uid() = id);
create policy "Users can insert own profile" on profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);

-- Ingredients policies
create policy "Users can manage own ingredients" on ingredients for all using (auth.uid() = user_id);

-- Cook log policies
create policy "Users can manage own cook log" on cook_log for all using (auth.uid() = user_id);

-- Income policies
create policy "Users can manage own income" on income for all using (auth.uid() = user_id);

-- Expenses policies
create policy "Users can manage own expenses" on expenses for all using (auth.uid() = user_id);

-- Debts policies
create policy "Users can manage own debts" on debts for all using (auth.uid() = user_id);

-- Goals policies
create policy "Users can manage own goals" on goals for all using (auth.uid() = user_id);

-- ============================================
-- ACTIVITIES TABLE (daily time log)
-- ============================================
create table if not exists activities (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  name text not null,
  hours numeric not null,
  log_date date default current_date,
  created_at timestamptz default now()
);

alter table activities enable row level security;
create policy "Users can manage own activities" on activities for all using (auth.uid() = user_id);

-- ============================================
-- AUTO-UPDATE updated_at on profiles
-- ============================================
create or replace function update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger profiles_updated_at
  before update on profiles
  for each row execute function update_updated_at();

-- ============================================
-- AUTO-CREATE PROFILE ON SIGNUP
-- ============================================
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into profiles (id, name)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', 'Slacker'));
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();
