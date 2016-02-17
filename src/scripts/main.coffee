do ->
  editor = ace.edit 'editor'
  editor.getSession().setMode 'ace/mode/html'

  $('.js-run').on 'click', ->
    $.ajax({
      url: '/save',
      method: 'POST',
      data: {
        htmlContent: editor.getValue()
      }
    }).done (resp) ->
      $('.js-result').attr 'src', resp.filePath
