router = do require 'koa-router'
session = require 'koa-session'
checkAuth = require '../middleware/checkAuth'
adminAccess = require '../middleware/adminAccess'

module.exports = (app) ->
  app
  .use router.routes()
  .use router.allowedMethods()

  router.use session(app)

  router.get '/', require('./frontPage').get
  router.get '/login', require('./login').get
  router.post '/login', require('./login').post
  router.get '/logout', checkAuth, require('./logout')
  router.get '/editor', checkAuth, require('./editor').get
  router.post '/save', checkAuth, require('./savePage').post
  router.post '/pass', checkAuth, require('./passForm').post
  router.get '/quiz', checkAuth, require('./quiz').get
  router.post '/endQuiz', checkAuth, require('./endQuiz')
  router.get '/results', checkAuth, require('./results')
  router.get '/total', checkAuth, adminAccess, require('./total').get
  router.post '/saveResults', checkAuth, adminAccess, require('./total').save
  router.get '/users', checkAuth, adminAccess, require('./users')
  router.get '/roles', checkAuth, adminAccess, require('./roles')
  router.post '/addUser', checkAuth, adminAccess, require('./addUser')
  router.post '/removeUser', checkAuth, adminAccess, require('./removeuser')
  router.get '/quizBoard', checkAuth, adminAccess, require('./quizBoard')
  router.get '/quizResults', checkAuth, adminAccess, require('./quizResults')
  router.get '/layoutStepResults', checkAuth, adminAccess, require('./layoutStepResults')
  router.get '/saveFile/:user/:fileName', checkAuth, adminAccess, require('./saveFile')
  router.get '/next/:task', checkAuth, require('./editor').next
  router.post '/saveTaskResults', checkAuth, require('./editor').save
