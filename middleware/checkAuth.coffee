module.exports = (next) ->
  if not this.session.user
    this.throw 'Forbidden', 403
  yield next
