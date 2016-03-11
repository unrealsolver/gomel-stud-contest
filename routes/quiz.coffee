module.exports.get = (next) ->
  if not this.session.passedForm or this.session.passedQuiz
    this.throw 'Forbidden', 403
  yield this.render 'quiz'
