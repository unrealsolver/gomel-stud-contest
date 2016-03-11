db = require '../database'

module.exports.get = (next) ->
  resp = yield db.commonResults()
  console.log resp[0]
  yield this.render 'total', { results: resp[0] }

module.exports.save = (next) ->
  userId = this.request.body.userId
  step = this.request.body.step
  value = this.request.body.value

  resp = yield db.getUserResults userId

  if resp[0].length is 0
    yield db.createResultForUser userId, step, value
  else
    yield db.changeResultOfCurrentUser userId, step, value

  this.body = {
    status: 'ok'
  }

