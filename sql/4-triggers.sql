--
-- conversations
--
create trigger conversations_update_timestamp
  before update on conversations for each row
  execute procedure moddatetime (updated_at);

--
-- votes
--
create trigger votes_update_timestamp
  before update on votes for each row
  execute procedure moddatetime (updated_at);

