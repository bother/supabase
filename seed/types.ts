export type Data<T> = {
  data: Array<T>
  sql: Array<string>
}

export type User = {
  id: string
  email: string
}

export type Post = {
  id: number
  user_id: string
  body: string
  latitude: number
  longitude: number
  created_at: string
}

export type Vote = {
  post_id: number
  user_id: string
  vote: number
  created_at: string
}

export type Comment = {
  id: number
  post_id: number
  user_id: string
  comment: string
  created_at: string
}
