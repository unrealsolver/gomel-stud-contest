utils = require '../utils'
db = require '../database'

module.exports.get = (next) ->
  if this.session.passedQuiz
    this.throw 'Forbidden', 403
  yield this.render 'editor', { editorPage: true }

module.exports.save = (next) ->
  taskNumber = this.request.body.task
  time = this.request.body.time / 1000

  yield db.saveFirstStepResults this.session.user.id, taskNumber, time

  this.body = {
    status: 'ok'
  }

module.exports.next = (next) ->
  taskNumber = parseInt this.params.task

  task = utils.readTaskFile taskNumber

  if task is null
    this.throw 'No such task', 404

  nextTaskExists = utils.checkFileExists taskNumber + 1

  this.body = {
    task: task
    next: nextTaskExists
  }
