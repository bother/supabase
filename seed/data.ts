import {
  addMinutes,
  chance,
  chunk,
  formatISO,
  getJson,
  nanoid,
  parseISO,
  random,
  range,
  sample,
  subMinutes,
  uniqBy
} from './lib'
import { Comment, Data, Post, User, Vote } from './types'

export const getUsers = async (): Promise<Data<User>> => {
  const data: Array<string> = []

  const users = await getJson<Array<User>>('seed/json/users.json', () =>
    range(1_000).map(() => ({
      email: `${nanoid()}@bother.app`,
      id: chance.guid()
    }))
  )

  data.push('insert into auth.users (id, email) values')

  users.forEach((user, index) =>
    data.push(
      `  ('${user.id}', '${user.email}')${
        index === users.length - 1 ? ';' : ','
      }`
    )
  )

  return {
    data: users,
    sql: data
  }
}

export const getPosts = async (users: Array<User>): Promise<Data<Post>> => {
  const data: Array<string> = []

  const posts = await getJson<Array<Post>>('seed/json/posts.json', () =>
    range(1_000).map(index => ({
      body: chance.sentence(),
      created_at: formatISO(subMinutes(new Date(), random(1, 43_200))),
      id: index + 1,
      latitude: chance.latitude({
        max: 25.275249,
        min: 25.143338
      }),
      longitude: chance.longitude({
        max: 55.442353,
        min: 55.289051
      }),
      user_id: sample(users).id
    }))
  )

  data.push('insert into posts values')

  posts.forEach((post, index) =>
    data.push(
      `  (${post.id}, '${post.user_id}', '${post.body}', st_setsrid(st_point(${
        post.longitude
      }, ${post.latitude}), 4326), '${post.created_at}')${
        index === posts.length - 1 ? ';' : ','
      }`
    )
  )

  return {
    data: posts,
    sql: data
  }
}

export const getVotes = async (
  users: Array<User>,
  posts: Array<Post>
): Promise<Data<Vote>> => {
  const data: Array<string> = []

  const votes = await getJson<Array<Vote>>('seed/json/votes.json', () =>
    uniqBy(
      range(100_000).map(() => {
        const post = sample(posts)

        return {
          created_at: formatISO(
            addMinutes(parseISO(post.created_at), random(1, 60))
          ),
          post_id: post.id,
          user_id: sample(users).id,
          vote: chance.bool() ? 1 : -1
        }
      }),
      vote => `${vote.post_id};${vote.user_id}`
    )
  )

  chunk(votes, 1000).forEach(votes => {
    data.push('insert into votes values')

    votes.forEach((vote, index) =>
      data.push(
        `  ('${vote.user_id}', ${vote.post_id}, ${vote.vote}, '${
          vote.created_at
        }', '${vote.created_at}')${index === votes.length - 1 ? ';' : ','}`
      )
    )

    data.push('')
  })

  return {
    data: votes,
    sql: data
  }
}

export const getComments = async (
  users: Array<User>,
  posts: Array<Post>
): Promise<Data<Comment>> => {
  const data: Array<string> = []

  const comments = await getJson<Array<Comment>>(
    'seed/json/comments.json',
    () =>
      uniqBy(
        range(10_000).map(index => {
          const post = sample(posts)

          return {
            comment: chance.sentence(),
            created_at: formatISO(
              addMinutes(parseISO(post.created_at), random(1, 60))
            ),
            id: index + 1,
            post_id: post.id,
            user_id: sample(users).id
          }
        }),
        comment => `${comment.post_id};${comment.user_id}`
      )
  )

  chunk(comments, 1000).forEach(comments => {
    data.push('insert into comments values')

    comments.forEach((comment, index) =>
      data.push(
        `  (${comment.id}, '${comment.user_id}', ${comment.post_id}, '${
          comment.comment
        }', '${comment.created_at}')${
          index === comments.length - 1 ? ';' : ','
        }`
      )
    )

    data.push('')
  })

  return {
    data: comments,
    sql: data
  }
}
