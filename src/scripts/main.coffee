editorHtml = ace.edit 'editorHtml'
editorHtml.getSession().setMode 'ace/mode/html'

editorCss = ace.edit 'editorCss'
editorCss.getSession().setMode 'ace/mode/css'

submitFrameForm = (action) ->
  that = this
  $.ajax {
    url: action,
    method: 'POST',
    data: $(this).serialize()
  }
    .done (resp) ->
      body = $(that).parent 'body'
      body.empty()
      body.append $('<div>').text resp
    .error (xhr) ->
      $(that).find('.error').remove()
      for error in xhr.responseJSON
        for own key, value of error
          errorDiv = $('<div>').addClass 'error'
          $(that).append errorDiv.text value
  

$('.js-run').on 'click', ->
  $.ajax({
    url: '/save',
    method: 'POST',
    data: {
      htmlContent: editorHtml.getValue()
      cssContent: editorCss.getValue()
    }
  }).done (resp) ->
    jsResult = $('.js-result')
    jsResult.load ->
      form = $(this).contents().find 'form'

      form.on 'submit', (event) ->
        event.preventDefault()
        submitFrameForm.call this, $(this).attr 'action'

    jsResult.attr 'src', resp.filePath

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


