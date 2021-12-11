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
group by
  posts.id
order by
  posts.location <-> st_setsrid (st_point (longitude, latitude), 4326)::geometry
$$;

--
-- post: fetch
--
create or replace function fetch_post (postid bigint)
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
  left join comments on comments.post_id = postid
  left join votes on votes.post_id = postid
where
  posts.id = postid
group by
  posts.id
$$;

--
-- post: create
--
create or replace function create_post (userid uuid, body text, latitude float, longitude float)
  returns bigint
  language plpgsql
  as $$
declare
  nextid bigint;
begin
  insert into posts (user_id, body, location)
    values (userid, body, st_setsrid (st_point (longitude, latitude), 4326))
  returning
    id into nextid;
  insert into votes (user_id, post_id, vote)
    values (userid, nextid, 1);
  return nextid;
end;
$$;

--
-- conversations: start
--
create or replace function start_conversation (targettype conversation_target_type, targetid bigint, userid uuid, recipientid uuid)
  returns bigint
  language plpgsql
  as $$
declare
  nextid bigint;
begin
  select
    conversations.id into nextid
  from
    conversations
  where
    target_type = targettype
    and target_id = targetid
    and (user_id in (userid, recipientid)
      or recipient_id in (userid, recipientid));
  if nextid is not null then
    return nextid;
  end if;
  insert into conversations (target_type, target_id, user_id, recipient_id)
    values (targettype, targetid, userid, recipientid)
  returning
    id into nextid;
  return nextid;
end;
$$;

