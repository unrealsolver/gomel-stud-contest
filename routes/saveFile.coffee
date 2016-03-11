mime = require 'mime'
utils = require '../utils'


module.exports = (next) ->
  yield next
  userIdAndName = this.params.user
  fileName = this.params.fileName

  filePath = utils.getFilePath userIdAndName, fileName

  mimeType = mime.lookup filePath

  fileStream = utils.getFileStream filePath

  this.body = fileStream
  this.set "Content-disposition", "attachment; filename=#{fileName}"
  this.set "Content-type", mimeType
