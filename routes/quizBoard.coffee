db = require '../database'

module.exports = (next) ->
  yield this.render 'quizBoard'
