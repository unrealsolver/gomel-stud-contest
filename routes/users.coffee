db = require '../database'
Role = require '../models/role'
User = require '../models/user'
_ = require 'lodash'

module.exports = (next) ->
  usersResp = yield db.getAllUsers()
  usersRows = usersResp[0]
  rolesResp = yield db.getRoles()
  rolesRows = rolesResp[0]

  roles = []
  users = []

  for row in rolesRows
    roles.push(new Role(row.id, row.name))

  for row in usersRows
    role = _.find roles, { id: row.role }
    user = new User row.id, row.username, row.firstName, row.lastName, role
    users.push user

  yield this.render 'users', { users: users }
