koa = require 'koa'
serve = require 'koa-static'
router = require('koa-router')()
koaBody = require('koa-body')()
json = require 'koa-json'
fs = require 'fs'
app = koa()

app.use serve(__dirname + '/dist')

app.use json()

app
  .use router.routes()
  .use router.allowedMethods()


router.post '/save', koaBody, (next) ->
  yield next

  requestBody = this.request.body
  html = requestBody.htmlContent
  style = requestBody.styleContent
  script = requestBody.scriptContent

  if typeof html is 'undefined'
    html = ''
  if typeof style is 'undefined'
    style = ''
  if typeof script is 'undefined'
    script = ''

  fileForSave = "<html>
    <head>
      <style>
        #{style}
      </style>
    </head>
    <body>
      #{html}
      <script>
        #{script}
      <script>
    </body>
  </html>"

  fs.writeFileSync 'dist/result/result.html', fileForSave

  this.body = {
    status: 'ok',
    filePath: '/result/result.html'
  }

app.listen 3000

console.log 'Listening port 3000'
