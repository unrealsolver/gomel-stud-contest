db = require '../database'
User = require '../models/user'
Role = require '../models/role'

module.exports.get = (next) ->
  yield this.render('login')

sendLoginError = (status, message) ->
  this.status = status
  this.body = {
    error: message
  }

module.exports.post = (next) ->
  username = this.request.body.username
  password = this.request.body.password

  resp = yield db.getUser(username)
  rows = resp[0]

  if rows.length
    if User.checkPassword rows[0].password, password
      console.log rows[0].role
      resp = yield db.getRole(rows[0].role)
      roleRows = resp[0]
      role = new Role roleRows[0].id, roleRows[0].name
      user = new User(rows[0].id, rows[0].username, rows[0].firstName, rows[0].lastName, role)
      this.session.user = user
      this.body = {}
    else
      sendLoginError.apply this, [403, 'Wrong password!']
  else
    sendLoginError.apply this, [404, 'User not found']
