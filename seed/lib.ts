import { Chance } from 'chance'
import fs from 'fs'
import { customAlphabet } from 'nanoid'
import { promisify } from 'util'

export const writeFile = promisify(fs.writeFile)
export const readFile = promisify(fs.readFile)
export const stat = promisify(fs.stat)

export const nanoid = customAlphabet('abcdefghijklmnopqrstuvwxyz', 24)

export const chance = new Chance()

export { addMinutes, formatISO, parseISO, subMinutes } from 'date-fns'
export { chunk, random, range, sample, uniqBy } from 'lodash'

export const getJson = async <T>(
  path: string,
  fallback: () => T
): Promise<null | T> => {
  try {
    await stat(path)
  } catch {
    const data = fallback()

    await putJson(path, data)

    return data
  }

  const data = await readFile(path, 'utf8')

  return JSON.parse(data)
}

export const putJson = async <T>(path: string, data: T): Promise<void> =>
  writeFile(path, JSON.stringify(data), 'utf8')
