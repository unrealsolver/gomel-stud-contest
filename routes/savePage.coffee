utils = require '../utils'

module.exports.post = (next) ->
  yield next

  if not this.session.user
    this.redirect '/login'
    this.status = 301

  requestBody = this.request.body
  html = requestBody.htmlContent
  css = requestBody.cssContent
  script = requestBody.scriptContent

  if typeof html is 'undefined'
    html = ''
  if typeof css is 'undefined'
    css = ''
  if typeof script is 'undefined'
    script = ''

  path = utils.saveFile html, css, script, this.session.user.id, this.session.user.username, requestBody.taskNumber

  this.body = {
    status: 'ok',
    filePath: path,
  }
