import { getComments, getPosts, getUsers, getVotes } from './data'
import { writeFile } from './lib'

const main = async () => {
  const users = await getUsers()
  const posts = await getPosts(users.data)
  const votes = await getVotes(users.data, posts.data)
  const comments = await getComments(users.data, posts.data)

  console.log('users', users.data.length)
  console.log('posts', posts.data.length)
  console.log('votes', votes.data.length)
  console.log('comments', comments.data.length)

  const data = [users.sql, posts.sql, votes.sql, comments.sql].map(data =>
    data.join('\n')
  )

  ;['posts', 'votes', 'comments'].forEach(table =>
    data.push(
      `select pg_catalog.setval(pg_get_serial_sequence('${table}', 'id'), (select max(id) from ${table}) + 1);`
    )
  )

  await writeFile(`sql/8-seed.sql`, data.join('\n'), 'utf8')
}

main()
