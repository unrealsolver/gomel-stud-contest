fs = require 'fs'
mkdirp = require 'mkdirp'
sha1 = require 'sha1'
path = require 'path'

RESULTS_DIR = "dist/results/"
module.exports.saveFile = (html, css, script, uid, username, taskNumber) ->
  DIR = RESULTS_DIR + uid + '_' + username
  fileForSave = "
    <!DOCTYPE html>
    <html>
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
  fs.writeFileSync "#{DIR}/task_#{taskNumber}.html", fileForSave

  "/results/#{uid}_#{username}/task_#{taskNumber}.html"

module.exports.readTaskFile = (taskNumber) ->
  PATH = "src/tasks/task_#{taskNumber}.task"

  if not fs.existsSync PATH
    return null

  fs.readFileSync PATH, 'utf8'

module.exports.checkFileExists = (taskNumber) ->
  PATH = "src/tasks/task_#{taskNumber}.task"
  fs.existsSync PATH

module.exports.getFilePath = (idAndName, fileName) ->
  dir = path.join RESULTS_DIR , idAndName
  path.join dir, "#{fileName}.html"

module.exports.getFileStream = (file) ->
  fs.createReadStream file

module.exports.getCountOfFirstStepTasks = ->
  DIR = "src/tasks"
  fs.readdirSync(DIR).length

module.exports.getCountOfQuizTasks = ->
  DIR = "src/cssTests/tasks"
  fs.readdirSync(DIR).length

module.exports.encryptPass = (password) ->
  sha1 password
