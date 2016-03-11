module.exports = (next) ->
  if this.session.passedQuiz
    this.throw 'You have already passed the quiz!', 403

  this.session.passedQuiz = true

  this.body = {
    status: 'ok'
  }
