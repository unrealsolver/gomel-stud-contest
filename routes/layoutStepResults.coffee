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
      tasks = {}
      tasks[row.task] = row.time
      users.push {
        id: row.id
        username: row.username,
        firstName: row.firstName,
        lastName: row.lastName,
        tasks: if task.task is null then {} else tasks,
        totalTime: row.time
      }
      continue

    users[index].tasks[row.task] = row.time
    users[index].totalTime += row.time

  yield this.render 'layoutStepResults', {
    users: users,
    countOfTasks: utils.getCountOfFirstStepTasks()
  }
