--
-- conversations
--
create trigger conversations_update_timestamp
  before update on conversations for each row
  execute procedure moddatetime (updated_at);

--
-- messages: update conversation
--
create trigger messages_update_timestamp_on_conversation
  after insert on messages for each row
  execute procedure update_conversation (conversation_id);

--
-- votes
--
create trigger votes_update_timestamp
  before update on votes for each row
  execute procedure moddatetime (updated_at);

