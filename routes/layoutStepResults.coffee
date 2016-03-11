db = require '../database'
utils = require '../utils'
_ = require 'lodash'

module.exports = (next) ->
  resp = yield db.firstStepResults()
  rows = resp[0]
  users = []

  for row in rows
    index = _.findIndex users, { id: row.id }

    task =
      task: row.task
      time: row.time

    if index is -1
      users.push {
        id: row.id
        username: row.username,
        firstName: row.firstName,
        lastName: row.lastName
        tasks: [task],
        totalTime: row.time
      }
      continue

    users[index].tasks.push task
    users[index].totalTime += row.time

  console.log users[1].tasks

  yield this.render 'layoutStepResults', { users: users }
