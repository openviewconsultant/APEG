-- Create table for storing Played Rounds
create table public.rounds (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  course_name text not null,
  course_location text,
  date_played timestamp with time zone default timezone('utc'::text, now()) not null,
  total_score integer default 0,
  status text default 'in_progress', -- 'in_progress', 'completed'
  
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create table for storing Hole-by-Hole Scores
create table public.round_scores (
  id uuid default gen_random_uuid() primary key,
  round_id uuid references public.rounds(id) on delete cascade not null,
  hole_number integer not null,
  par integer not null,
  score integer not null,
  
  -- Optional extended stats for future use
  fairways_hit boolean,
  gir boolean, -- Greens in Regulation
  putts integer,
  
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  
  -- Ensure unique hole per round
  unique(round_id, hole_number)
);

-- Enable Row Level Security
alter table public.rounds enable row level security;
alter table public.round_scores enable row level security;

-- Policies for Rounds
create policy "Users can view their own rounds" on public.rounds
  for select using (auth.uid() = user_id);

create policy "Users can insert their own rounds" on public.rounds
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own rounds" on public.rounds
  for update using (auth.uid() = user_id);

-- Policies for Scores
create policy "Users can view their own scores" on public.round_scores
  for select using (
    exists ( select 1 from public.rounds where id = round_scores.round_id and user_id = auth.uid() )
  );

create policy "Users can insert their own scores" on public.round_scores
  for insert with check (
    exists ( select 1 from public.rounds where id = round_scores.round_id and user_id = auth.uid() )
  );

create policy "Users can update their own scores" on public.round_scores
  for update using (
    exists ( select 1 from public.rounds where id = round_scores.round_id and user_id = auth.uid() )
  );
