db = require '../database'

module.exports = (next) ->
  resp = yield db.getRoles()
  roles = resp[0]

  this.body = {
    roles: roles
  }
