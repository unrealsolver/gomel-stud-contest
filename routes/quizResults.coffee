db = require '../database'
_ = require 'lodash'
utils = require '../utils'

module.exports = (next) ->
  resp = yield db.quizResults()
  rows = resp[0]

  users = []

  for row in rows
    userIndex = _.findIndex users, { username: row.username }

    if userIndex is -1
      tasksTime = {}
      tasksSelector = {}
      tasksTime[row.task] = row.time
      tasksSelector[row.task] = row.length
      users.push {
        username: row.username,
        firstName: row.firstName,
        lastName: row.lastName,
        tasksTime: if row.task is null then {} else tasksTime,
        tasksSelectorLength: if row.task is null then {} else tasksSelector,
        totalTime: row.time
      }
      continue

    users[userIndex].totalTime += row.time
    users[userIndex].tasksTime[row.task] = row.time
    users[userIndex].tasksSelectorLength[row.task] = row.length

  yield this.render 'quizResults', {
    users: users,
    countOfTasks: utils.getCountOfQuizTasks()
  }
