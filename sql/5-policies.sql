--
-- posts
--
alter table posts enable row level security;

create policy "users can create posts" on posts
  for insert
    with check (auth.uid () = user_id);

create policy "users can view all posts" on posts
  for select
    using (auth.role () = 'authenticated');

create policy "users can update their own posts" on posts
  for update
    using (auth.uid () = user_id);

create policy "users can delete their own posts" on posts
  for delete
    using (auth.uid () = user_id);

--
-- votes
--
alter table votes enable row level security;

create policy "users can create votes" on votes
  for insert
    with check (auth.uid () = user_id);

create policy "users can view all votes" on votes
  for select
    using (auth.role () = 'authenticated');

create policy "users can update their own votes" on votes
  for update
    using (auth.uid () = user_id);

create policy "users can delete their own votes" on votes
  for delete
    using (auth.uid () = user_id);

--
-- comments
--
alter table comments enable row level security;

create policy "users can create comments" on comments
  for insert
    with check (auth.uid () = user_id);

create policy "users can view all comments" on comments
  for select
    using (auth.role () = 'authenticated');

create policy "users can update their own comments" on comments
  for update
    using (auth.uid () = user_id);

create policy "users can delete their own comments" on comments
  for delete
    using (auth.uid () = user_id);

--
-- conversations
--
alter table conversations enable row level security;

create policy "users can create conversations" on conversations
  for insert
    with check (auth.role () = 'authenticated');

create policy "users can view their own conversations" on conversations
  for select
    using (user_id = auth.uid ()
      or recipient_id = auth.uid ());

--
-- messages
--
alter table messages enable row level security;

create policy "users can create messages" on messages
  for insert
    with check (auth.uid () = user_id);

create policy "users can view messages in their conversations" on messages
  for select
    using (exists (
      select
        id
      from
        conversations
      where
        conversations.id = conversation_id and (conversations.user_id = auth.uid () or conversations.recipient_id = auth.uid ())));

