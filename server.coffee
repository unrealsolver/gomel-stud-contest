koa = require 'koa'
serve = require 'koa-static'
router = require('koa-router')()
koaBody = require('koa-body')()
json = require 'koa-json'
session = require 'koa-session'
validate = require 'koa-validate'
fs = require 'fs'
mkdirp = require 'mkdirp'
app = koa()

app.use json()
app
  .use router.routes()
  .use router.allowedMethods()
app.keys = ['contest']
router.use session(app)
app.use validate()

app.use serve(__dirname + '/dist')

saveFile = (html, css, script, sessionId)->
  DIR = 'dist/results'
  fileForSave = "<html>
    <head>
      <style type='text/css'>
        #{css}
      </style>
    </head>
    <body>
      #{html}
      <script>
        #{script}
      </script>
    </body>
  </html>"

  mkdirp.sync DIR
  fs.writeFileSync "#{DIR}/#{sessionId}.html", fileForSave

  "/results/#{sessionId}.html"

router.all '/', (next) ->
  if this.session.isNew then this.session.save()
  yield next

router.post '/save', koaBody, (next) ->
  yield next
  requestBody = this.request.body
  html = requestBody.htmlContent
  css = requestBody.cssContent
  script = requestBody.scriptContent

  sessionId = this.cookies.get 'koa:sess.sig'

  if typeof html is 'undefined'
    html = ''
  if typeof css is 'undefined'
    css = ''
  if typeof script is 'undefined'
    script = ''

  path = saveFile html, css, script, sessionId

  this.body = {
    status: 'ok',
    filePath: path,
  }

router.post '/pass', koaBody, (next) ->
  yield next
  requestBody = this.request.body
  this.checkBody('firstName').notEmpty().isAlpha()
  this.checkBody('lastName').notEmpty().isAlpha()

  if this.errors
    this.status = 400
    this.body = this.errors
    return

  this.session.user = {
    firstName: requestBody.firstName,
    lastName: requestBody.lastName
  }

  this.body = 'Hello ' + this.session.user.firstName + ' ' + this.session.user.lastName

app.listen 3000

console.log 'Listening port 3000'
