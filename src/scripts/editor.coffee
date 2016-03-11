codeRunner = $('.js-run')
startTime = 0

editorHtml = ace.edit 'editorHtml'
editorHtml.getSession().setMode 'ace/mode/html'

editorCss = ace.edit 'editorCss'
editorCss.getSession().setMode 'ace/mode/css'

setLocalStorage = (key, value) ->
  localStorage.setItem key, value

getLocalStorage = (key) ->
  localStorage.getItem key

taskNumber = getLocalStorage('taskNumber') || 1

# Fills editors and popup with new task information
showTask = (task) ->
  editorHtml.setValue task.html, -1
  editorCss.setValue task.css, -1
  taskPopup = $('.task-popup')
  taskPopup.empty()
  taskPopup.html task.text
  codeRunner.trigger 'click'
  $('.js-result').attr 'src', ''
  startTime = new Date().getTime()

# Loads new task from the server
loadTask = (nextTaskExists) ->

  nextTaskExists = typeof(nextTaskExists) is 'undefined' ? true : nextTaskExists

  parseFile = (data) ->
    blocks = data.split '*'
    {
      html: blocks[0],
      css: blocks[1],
      text: blocks[2]
    }

  $.get "/next/#{taskNumber}"
    .done (resp) ->
      nextTaskBtn = $('.next-task')

      if resp.next
        nextTaskBtn.show()
      else
        nextTaskBtn.hide()

      setLocalStorage 'taskNumber', taskNumber
      task = parseFile(resp.task)
      showTask(task)

saveTaskResults = () ->
  time = new Date().getTime() - startTime

  $.post '/saveTaskResults', { 
    task: taskNumber,
    time: time
  }
    .done ->
      taskNumber++
      loadTask()
    .error ->
      console.log 'Error while saving task results'

startQuiz = ->
  localStorage.removeItem 'taskNumber'
  location.href = '/quiz'

# Submitting user's form inside the frame
submitFrameForm = (action) ->
  that = this
  $.ajax {
    url: action,
    method: 'POST',
    data: $(this).serialize()
  }
    .done (resp) ->
      QUIZ_ROUTE = '/quiz'
      body = $(that).parent 'body'
      body.empty()
      body.append resp
      saveTaskResults()
      socketIo.emit 'ready to start'

    .error (xhr) ->
      $(that).find('.error').remove()
      for error in xhr.responseJSON
        for own key, value of error
          errorDiv = $('<div>').addClass 'error'
          $(that).append errorDiv.text value
  
loadTask()

$('.next-task').on 'click', ->
  saveTaskResults()

# Run written code inside the editor
codeRunner.on 'click', ->
  $.ajax({
    url: "/save/",
    method: 'POST',
    data: {
      htmlContent: editorHtml.getValue(),
      cssContent: editorCss.getValue(),
      taskNumber: taskNumber
    }
  }).done (resp) ->
    jsResult = $('.js-result')
    jsResult.load ->
      form = $(this).contents().find 'form'
      form.on 'submit', (event) ->
        submitFrameForm.call this, $(this).attr 'action'
        event.preventDefault()
        event.stopImmediatePropagation()

    jsResult.attr 'src', resp.filePath

socketIo.on 'start quiz', ->
  startQuiz()

bar = $('.bar')
editorHtmlDomElement = $('#editorHtml')
editorCssDomElement = $('#editorCss')
MIN_SIZE = 5
editorsBlock = $('.editors')
resultsBlock = $('.results')

$('.horizontal-divider')
  .mousedown (event) ->
    that = this
    startY = event.pageY
    startPosition = $(this).position()
    editorsHeight = editorsBlock.height()
    editorHtmlHeight = editorHtmlDomElement.height() * 100 / editorsHeight
    editorCssHeight = editorCssDomElement.height() * 100 / editorsHeight
    $(document).mouseup (event) ->

      $(this).off 'mousemove'
      $(this).off 'mouseup'

    $(document).mousemove (event) ->
      offset = event.pageY - startY
      offsetPer = offset * 100 / editorsHeight

      newHeightHtmlEditor = editorHtmlHeight + offsetPer
      newHeightCssEditor = editorCssHeight - offsetPer

      if newHeightHtmlEditor <= MIN_SIZE or newHeightCssEditor <= MIN_SIZE
        return

      editorHtmlDomElement.css('height', newHeightHtmlEditor + '%')
      editorCssDomElement.css('height', newHeightCssEditor + '%')

      newTopPosition = startPosition.top * 100 / editorsHeight + offsetPer

      $(that).css('top', newTopPosition + '%')

      editorHtml.resize()
      editorCss.resize()
        

$('.vertical-divider')
  .mousedown (event) ->
    that = this
    startX = event.pageX
    startPosition = $(this).position()
    barWidth = bar.width()
    editorsBlockWidth = editorsBlock.width() * 100 / barWidth
    resultsBlockWidth = resultsBlock.width() * 100 / barWidth
    $overlayer = $('<div>').addClass 'overlayer'
    resultsBlock.append $overlayer

    $(document).mouseup (event) ->
      $(this).off 'mousemove'
      $(this).off 'mouseup'

      $overlayer.remove()

    $(document).mousemove (event) ->
      offset = event.pageX - startX
      offsetPer = offset * 100 / barWidth
      newEditorsWidth = editorsBlockWidth + offsetPer
      newResultsWidth = resultsBlockWidth - offsetPer

      if newEditorsWidth <= MIN_SIZE or newResultsWidth <= MIN_SIZE
        return

      resultsBlock.css('width', newResultsWidth + '%')
      editorsBlock.css('width', newEditorsWidth + '%')

      newLeftPosition = startPosition.left * 100 / barWidth + offsetPer

      $(that).css('left', newLeftPosition + '%')

      editorHtml.resize()
      editorCss.resize()


