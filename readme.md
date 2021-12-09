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

### Tables

```
sql/2-tables.sql
```

Creates the tables for our schema;

- `posts`
- `votes`
- `comments`
- `conversations`
- `partners`
- `messages`

### Triggers

```
sql/3-triggers.sql
```

Sets up the triggers we need;

- `conversations_update_timestamp`
- `votes_update_timestamp`

### Policies

```
sql/4-policies.sql
```

Sets up the row level security policies we need;

- `conversations_update_timestamp`
- `votes_update_timestamp`

### Functions

```
sql/5-functions.sql
```

Creates the stored procedures we need;

- `feed_popular`
- `feed_latest`
- `feed_nearby`
- `fetch_post`

And the custom types;

- `feed_post`

### Seed

```
sql/6-seed.sql
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

## Todo

- [ ] Policy: `conversations`
- [ ] Policy: `partners`
- [ ] Policy: `messages`
- [ ] Seed: Change `votes`.`vote` to up votes only