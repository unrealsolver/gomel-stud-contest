koa = require 'koa'
serve = require 'koa-static'
koaBody = do require 'koa-body'
json = require 'koa-json'
validate = require 'koa-validate'
path = require 'path'
config = require 'config'
router = require './routes'
views = require 'koa-views'
http = require 'http'
socket = require 'socket.io'
cookie = require 'cookie'
db = require './database'

app = koa()
httpServer = http.createServer app.callback()
io = socket httpServer

app.use json()
app.use koaBody
app.use validate()
app.keys = ['contest']

app.use(views path.join(__dirname, '/views') , {
  extension: 'jade'
})

app.use (next) ->
  try
    yield next
  catch error
    console.log error
    this.status = error.status || 500
    yield this.render 'error', {
      errorStatus: error.status,
      errorMessage: error.message
    }

app.use (next) ->
  this.state.user = this.session.user
  this.state.passed = this.session.passedQuiz
  yield next

router(app)

app.use serve(path.join __dirname, '/dist' )

db.createConnection()

io.use (socket, next) ->
  handShakeData = socket.request
  if handShakeData.headers.cookie && handShakeData.headers.cookie.indexOf('koa:sess') > -1
    cookieData = cookie.parse(handShakeData.headers.cookie)['koa:sess']
    parsedUser = JSON.parse(new Buffer(cookieData, 'base64'))
    handShakeData.user = parsedUser.user
    next()
  else
    next(new Error('Not authorized'))

io.on 'connection', (socket) ->
  socket.on 'ready to start', ->
    socket.join 'ready room'
    socket.broadcast.emit 'add user', socket.request.user

  socket.on 'begin', (data, callback) ->
    io.to 'ready room'
      .emit 'start quiz'
    db.clearQuizResults()
    callback()

  socket.on 'pass test', (data) ->
    data.user = socket.request.user
    socket.broadcast.emit 'test passed', data
    db.saveQuizResults data, socket.request.user.id
  
httpServer.listen config.get('port')
