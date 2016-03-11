$('.js-show-popup').on 'click', ->
  overlay = $('.popup-overlay')
  popup = $('.popup')

  overlay.css 'visibility', 'visible'
  popup.css 'opacity', 1

  closePopup = ->
    popup.css 'opacity', 0
    overlay.css 'visibility', ''

  overlay.on 'click', (event) ->
    if $(event.target)[0] is overlay[0]
      closePopup()

  $('.close-popup-btn').on 'click', (event) ->
    closePopup()
    $(this).unbind 'click'
    event.stopPropagation
