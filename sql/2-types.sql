--
-- feed: post
--
create type feed_post as (
  id bigint,
  user_id uuid,
  body text,
  comments bigint,
  votes bigint,
  latitude float,
  longitude float,
  created_at timestamp with time zone
);

--
-- profile: gender
--
create type profile_gender as enum (
  'male',
  'female',
  'other'
);

