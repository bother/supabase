--
-- conversations: fetch
--
create view conversations_with_last_message as
select
  *
from
  conversations
  left join lateral (
    select
      conversation_id,
      body as last_message_body,
      created_at as last_message_created_at
    from
      messages
    where
      conversation_id = conversations.id
    order by
      created_at desc
    limit 1) as last_message on conversations.id = last_message.conversation_id
where
  one_id = auth.uid ()
  or two_id = auth.uid ()
order by
  updated_at desc
