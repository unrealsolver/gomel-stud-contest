module.exports = (next) ->
  if this.session.user.role.name isnt 'admin'
    this.throw 'Access denied', 401

  yield next
