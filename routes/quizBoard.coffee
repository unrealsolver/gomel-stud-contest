db = require '../database'
utils = require '../utils'

module.exports = (next) ->
  yield this.render 'quizBoard', { countOfTasks: utils.getCountOfQuizTasks() }
