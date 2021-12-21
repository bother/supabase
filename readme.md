# Bother

Supabase migration scripts

## Scripts

### Reset

> Danger zone

```
sql/0-reset.sql
```

### Extensions

> Can only be run from Supabase dashboard

```
sql/1-extensions.sql
```

Installs the required extensions;

- `postgis`
- `moddatetime`

### Types

```
sql/2-types.sql
```

Creates up the types we need;

- `feed_post`
- `profile_gender`

### Tables

```
sql/3-tables.sql
```

Creates the tables for our schema;

- `profiles`
- `posts`
- `votes`
- `comments`
- `conversations`
- `conversation_members`
- `messages`

### Triggers

```
sql/4-triggers.sql
```

Sets up the triggers we need;

- `on_auth_user_created`
- `messages_update_timestamp_on_conversations`
- `votes_update_timestamp`

### Policies

```
sql/5-policies.sql
```

Sets up the row level security policies we need on our tables;

#### `profiles`

- `users can view all profiles`
- `users can update their own profiles`

#### `posts`

- `users can create posts`
- `users can view all posts`
- `users can update their own posts`
- `users can delete their own posts`

#### `votes`

- `users can create votes`
- `users can view all votes`
- `users can update their own votes`
- `users can delete their own votes`

#### `comments`

- `users can create comments`
- `users can view all comments`
- `users can update their own comments`
- `users can delete their own comments`

#### `conversations`

- `users can view their own conversations`

#### `conversation_members`

- `users can view their own conversation members`

#### `messages`

- `users can create messages`
- `users can view messages in their conversations`

### Functions

```
sql/6-functions.sql
```

Creates the stored procedures we need;

- `feed_popular`
- `feed_latest`
- `feed_nearby`
- `fetch_post`
- `create_post`
- `start_conversation`
- `update_conversation_timestamp`
- `handle_new_user`

### Views

> Not used anymore

```
sql/7-views.sql
```

### Seed

```
sql/8-seed.sql
```

Generates the SQL dump we can import into our database.

- Creates 1,000 users
- Creates 1,000 posts
- Creates 100,000 votes
- Creates 10,000 comments

## Seed

There's a seed generator script, powered by [`lodash`](https://lodash.com) and [`chance`](https://chancejs.com).

### Run

`yarn generate` will compile the data into SQL files.

### Clean

If you make any changes to the schema, you need to `yarn clean` to delete the source JSON files so updated data can be generated with `yarn generate`.

Seed data is cached in JSON files so we can reference `post` and `user` ids for `vote`s and `comment`s.
