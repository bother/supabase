--
-- conversations
--
create trigger conversations_update_timestamp
  before update on conversations for each row
  execute procedure moddatetime (updated_at);

--
-- messages: update timestamps on conversations
--
create trigger messages_update_timestamps_on_conversations
  after insert on messages for each row
  execute procedure update_conversation ();

--
-- votes
--
create trigger votes_update_timestamp
  before update on votes for each row
  execute procedure moddatetime (updated_at);

