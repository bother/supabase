--
-- users: create new public user on auth.users
--
create trigger on_auth_user_created
  after insert on auth.users for each row
  execute procedure handle_new_user ();

--
-- messages: update timestamp on conversations
--
create trigger messages_update_timestamp_on_conversations
  after insert on messages for each row
  execute procedure update_conversation_timestamp ();

--
-- votes
--
create trigger votes_update_timestamp
  before update on votes for each row
  execute procedure moddatetime (updated_at);

