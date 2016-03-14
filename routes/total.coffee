db = require '../database'
utils = require '../utils'
_ = require 'lodash'

groupByUser = (rows) ->
  users = []
  for row in rows
    index = _.findIndex users, { userId: row.userId }
    if index is -1
      tasks = {}
      tasks[row.task] = row.mark
      users.push {
        userId: row.userId,
        firstName: row.firstName,
        lastName: row.lastName,
        tasks: if row.task is null then {} else tasks,
        totalMark: if row.task is null then 0 else row.mark
      }
      continue

    users[index].tasks[row.task] = row.mark
    users[index].totalMark += row.mark
  users

module.exports.get = (next) ->
  FIRST_STEP = 1
  SECOND_STEP = 2
  firstStepResp = yield db.commonResults(FIRST_STEP)
  quizStepResp = yield db.commonResults(SECOND_STEP)
  console.log firstStepResp

  firstStepResults = groupByUser(firstStepResp[0])
  quizStepResults = groupByUser(quizStepResp[0])

  console.log firstStepResults

  yield this.render 'total', { 
    firstStepResults: firstStepResults,
    quizStepResults: quizStepResults,
    countOfFirstStepTasks: utils.getCountOfFirstStepTasks(),
    countOfQuizTasks: utils.getCountOfQuizTasks()
  }

module.exports.save = (next) ->
  userId = this.request.body.userId
  step = this.request.body.step
  task = this.request.body.task
  value = this.request.body.value

  resp = yield db.getUserResults userId, step, task

  if resp[0].length is 0
    yield db.createResultForUser userId, step, task, value
  else
    yield db.changeResultOfCurrentUser userId, step, task, value

  this.body = {
    status: 'ok'
  }

