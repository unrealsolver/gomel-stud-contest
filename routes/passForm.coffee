module.exports.post = (next) ->
  yield next
  requestBody = this.request.body
  this.checkBody('firstName').notEmpty().isAlpha()
  this.checkBody('lastName').notEmpty().isAlpha()

  if this.errors
    this.status = 400
    this.body = this.errors
  else
    currentUser = this.session.user
    this.session.passedForm = true
    if requestBody.firstName is currentUser.firstName and 
    requestBody.lastName is currentUser.lastName
      yield this.render 'continueToQuiz'
    else
      this.status = 403
      this.body = [{error: 'No such user!'}]

