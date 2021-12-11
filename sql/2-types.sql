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
-- conversation: target_type
--
create type conversation_target_type as enum (
  'post',
  'comment'
);

