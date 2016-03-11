db = require '../database'
_ = require 'lodash'

module.exports = (next) ->
  resp = yield db.quizResults()
  rows = resp[0]

  users = []

  for row in rows
    userIndex = _.findIndex users, { username: row.username }
    taskInfo = {
      task: row.task,
      selectorLength: row.length,
      time: row.time
    }
    if userIndex is -1
      users.push {
        username: row.username,
        firstName: row.firstName,
        lastName: row.lastName,
        tasks: [taskInfo],
        totalTime: row.time
      }
      continue

    users[userIndex].totalTime += row.time
    users[userIndex].tasks.push taskInfo

  yield this.render 'quizResults', { users: users }
