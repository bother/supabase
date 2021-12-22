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
-- feed: user
--
create or replace function feed_user ()
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
  posts.user_id = auth.uid ()
group by
  posts.id
order by
  posts.created_at desc
$$;

--
-- post: fetch
--
create or replace function fetch_post ("postId" bigint)
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
  left join comments on comments.post_id = "postId"
  left join votes on votes.post_id = "postId"
where
  posts.id = "postId"
group by
  posts.id
$$;

--
-- post: create
--
create or replace function create_post (body text, latitude float, longitude float)
  returns bigint
  language plpgsql
  as $$
declare
  "nextId" bigint;
begin
  insert into posts (user_id, body, location)
    values (auth.uid (), body, st_setsrid (st_point (longitude, latitude), 4326))
  returning
    id into "nextId";
  insert into votes (user_id, post_id, vote)
    values (auth.uid (), "nextId", 1);
  return "nextId";
end;
$$;

--
-- conversations: start
--
create or replace function start_conversation ("postId" bigint, "recipientId" uuid, "commentId" bigint default null)
  returns bigint
  language plpgsql
  security definer
  as $$
declare
  "nextId" bigint;
begin
  select distinct
    conversations.id into "nextId"
  from
    conversation_members
    inner join conversations on conversations.id = conversation_members.conversation_id
  where
    conversation_members.user_id in (auth.uid (), "recipientId")
    and conversations.post_id = "postId"
    and case when "commentId" is null then
      conversations.comment_id is null
    else
      conversations.comment_id = "commentId"
    end
  group by
    conversations.id
  having
    count(conversations.id) = 2;
  if "nextId" is null then
    insert into conversations (post_id, comment_id)
      values ("postId", "commentId")
    returning
      id into "nextId";
    insert into conversation_members (conversation_id, user_id, last_seen_at)
      values ("nextId", auth.uid (), now());
    insert into conversation_members (conversation_id, user_id)
      values ("nextId", "recipientId");
  end if;
  return "nextId";
end;
$$;

--
-- trigger: update conversation timestamp on new message
--
create or replace function update_conversation_timestamp ()
  returns trigger
  language plpgsql
  security definer
  as $$
begin
  update
    conversations
  set
    updated_at = now()
  where
    id = new.conversation_id;
  update
    conversation_members
  set
    last_seen_at = now()
  where
    conversation_id = new.conversation_id
    and user_id = auth.uid ();
  return new;
end;
$$;

--
-- trigger: create public.profiles from auth.users
--
create or replace function handle_new_user ()
  returns trigger
  language plpgsql
  security definer
  set search_path = public
  as $$
begin
  insert into profiles (id)
    values (new.id);
  return new;
end;
$$;

