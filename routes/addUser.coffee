db = require '../database'
User = require '../models/user'
Role = require '../models/role'

module.exports = (next) ->
  username = this.request.body.username
  password = this.request.body.password
  firstName = this.request.body.firstName
  lastName = this.request.body.lastName
  roleId = this.request.body.role

  resp = yield db.getUser username
  userRows = resp[0]
  if userRows.length
    this.throw 'Username is already used'
  saveResp = yield db.saveUser(username, firstName, lastName, roleId, User.getEncryptedPassword password)
  roleResp = yield db.getRole roleId
  roleRows = roleResp[0]
  role = new Role roleRows[0].id, roleRows[0].name

  user = new User saveResp[0].insertId, username, firstName, lastName, role

  this.body = {
    status: 'ok',
    user: user
  }
