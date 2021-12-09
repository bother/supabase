--
-- feed: type
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
-- feed: popular
--
create or replace function feed_popular ()
  returns setof feed_post
  language sql
  as $$
  select
    posts.id,
    posts.user_id,
    posts.body,
    coalesce(count(comments.id), 0) as comments,
    coalesce(sum(votes.vote), 0) as votes,
    st_y (posts.location) as latitude,
    st_x (posts.location) as longitude,
    posts.created_at
  from
    posts
  left join comments on comments.post_id = posts.id
  left join votes on votes.post_id = posts.id
where
  posts.created_at > now()::date - interval '24 hours'
group by
  posts.id
order by
  votes desc
$$;

--
-- feed: latest
--
create or replace function feed_latest ()
  returns setof feed_post
  language sql
  as $$
  select
    posts.id,
    posts.user_id,
    posts.body,
    coalesce(count(comments.id), 0) as comments,
    coalesce(sum(votes.vote), 0) as votes,
    st_y (posts.location) as latitude,
    st_x (posts.location) as longitude,
    posts.created_at
  from
    posts
  left join comments on comments.post_id = posts.id
  left join votes on votes.post_id = posts.id
group by
  posts.id
order by
  posts.created_at desc
$$;

--
-- feed: nearby
--
create or replace function feed_nearby (latitude float, longitude float)
  returns setof feed_post
  language sql
  as $$
  select
    posts.id,
    posts.user_id,
    posts.body,
    coalesce(count(comments.id), 0) as comments,
    coalesce(sum(votes.vote), 0) as votes,
    st_y (posts.location) as latitude,
    st_x (posts.location) as longitude,
    posts.created_at
  from
    posts
  left join comments on comments.post_id = posts.id
  left join votes on votes.post_id = posts.id
where
  posts.created_at > now()::date - interval '24 hours'
group by
  posts.id
order by
  posts.location <-> st_setsrid (st_point (longitude, latitude), 4326)::geometry
$$;

--
-- post: fetch
--
create or replace function fetch_post (_id bigint)
  returns setof feed_post
  language sql
  as $$
  select
    posts.id,
    posts.user_id,
    posts.body,
    coalesce(count(comments.id), 0) as comments,
    coalesce(sum(votes.vote), 0) as votes,
    st_y (posts.location) as latitude,
    st_x (posts.location) as longitude,
    posts.created_at
  from
    posts
  left join comments on comments.post_id = _id
  left join votes on votes.post_id = _id
where
  posts.id = _id
group by
  posts.id
$$;

--
-- post: create
--
create or replace function create_post (user_id uuid, body text, latitude float, longitude float)
  returns bigint
  language plpgsql
  as $$
declare
  _id bigint;
begin
  insert into posts (user_id, body, location)
    values (user_id, body, st_setsrid (st_point (longitude, latitude), 4326))
  returning
    id into _id;
  insert into votes (user_id, post_id, vote)
    values (user_id, _id, 1);
  return _id;
end;
$$;

