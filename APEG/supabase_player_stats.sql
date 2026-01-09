-- Create a table to store player statistics
-- This table references the auth.users or public.profiles table depending on your setup. 
-- Assuming public.profiles exists and is the main user table.

create table public.player_stats (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null unique,
  
  -- Core Stats
  handicap_index numeric(4,1) default 54.0,
  total_rounds integer default 0,
  average_score numeric(4,1) default 0.0,
  best_score integer default 0,
  
  -- Performance Stats (Percentages)
  fairways_hit_rate numeric(4,1) default 0.0, -- Percentage 0-100
  gir_rate numeric(4,1) default 0.0, -- Greens in Regulation Percentage 0-100
  average_putts numeric(3,1) default 0.0,
  scrambling_rate numeric(4,1) default 0.0, -- Percentage of saving par after missing GIR
  
  -- Scoring Breakdown (Total Counts)
  total_eagles integer default 0,
  total_birdies integer default 0,
  total_pars integer default 0,
  total_bogeys integer default 0,
  total_doubles_worse integer default 0,
  
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security
alter table public.player_stats enable row level security;

-- Create Policy: Everyone can read stats (or restrict to friends if desired)
create policy "Public profiles are viewable by everyone."
  on public.player_stats for select
  using ( true );

-- Create Policy: Users can update their own stats
create policy "Users can update own stats."
  on public.player_stats for update
  using ( auth.uid() = user_id );

-- Create Policy: Users can insert their own stats
create policy "Users can insert own stats."
  on public.player_stats for insert
  with check ( auth.uid() = user_id );

-- Optional: Trigger to automatically create stats entry when a profile is created
-- (This depends on if you want it auto-created or created on first save)

-- Insert sample data for testing (Optional)
-- insert into public.player_stats (user_id, handicap_index, total_rounds, average_score, fairways_hit_rate, gir_rate, average_putts)
-- values ('YOUR_USER_ID_HERE', 5.4, 128, 76.5, 65.0, 58.0, 31.2);
