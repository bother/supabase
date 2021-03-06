--
-- profiles
--
create table profiles (
  id uuid primary key,
  age smallint,
  gender profile_gender,
  created_at timestamp with time zone default now() not null
);

--
-- posts
--
create table posts (
  id bigint generated by default as identity primary key,
  user_id uuid references profiles (id) not null,
  body text not null,
  location geometry(point, 4326) not null,
  created_at timestamp with time zone default now() not null
);

--
-- votes
--
create table votes (
  user_id uuid references profiles (id) not null,
  post_id bigint references posts (id) not null,
  vote smallint not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  primary key (user_id, post_id)
);

--
-- comments
--
create table comments (
  id bigint generated by default as identity primary key,
  user_id uuid references profiles (id) not null,
  post_id bigint references posts (id) not null,
  body text not null,
  created_at timestamp with time zone default now() not null
);

--
-- conversations
--
create table conversations (
  id bigint generated by default as identity primary key,
  post_id bigint references posts (id) not null,
  comment_id bigint references comments (id),
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null
);

--
-- conversation members
--
create table conversation_members (
  id bigint generated by default as identity primary key,
  conversation_id bigint references conversations (id) not null,
  user_id uuid references profiles (id) not null,
  last_seen_at timestamp with time zone,
  ended_at timestamp with time zone,
  created_at timestamp with time zone default now() not null
);

--
-- messages
--
create table messages (
  id bigint generated by default as identity primary key,
  conversation_id bigint references conversations (id) not null,
  user_id uuid references profiles (id) not null,
  body text not null,
  attachment jsonb,
  created_at timestamp with time zone default now() not null
);

