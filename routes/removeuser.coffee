db = require '../database'

module.exports = (next) ->
  userId = this.request.body.id
  yield db.removeUser userId

  this.body = {
    status: 'ok'
  }
