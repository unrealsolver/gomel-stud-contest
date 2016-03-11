module.exports = (next) ->
  yield next

  this.session = null
  this.redirect '/'
