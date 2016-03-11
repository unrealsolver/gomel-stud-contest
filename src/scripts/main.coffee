# Validates fields in the sign in form
validate = ->
  fields = Array.prototype.slice.call arguments, 0
  valid = true

  # Sets error class to parent of an invalid element
  # and shows appropriate message
  showError = (element, error) ->
    errorElement = $('<span>').text error
    element.parent 'div'
      .addClass 'error'
      .append errorElement

  for field in fields
    if not field.val().trim()
      showError(field, 'This field is required')
      valid = false

  valid

# Removes all validation errors
removeValidationErrors = (form) ->
  errors = form.find('.error').removeClass('error').find 'span'

  if errors
    for error in errors
      error.remove()

$('.sign-in').on 'submit', (event) ->
  event.preventDefault()
  
  removeValidationErrors $(this)
  serverErrorElement = $('.server-error').empty()

  if not validate $('input[name=username]'), $('input[name=password]')
    return

  $.ajax {
    url: $(this).attr('action'),
    method: 'POST',
    data: $(this).serialize()
  }
    .done ->
      location.href = '/'
    .fail (xhr) ->
      serverErrorElement.text xhr.responseJSON.error

# Open add user popup
$('.add-new-user').on 'click', (event) ->
  $.get '/roles'
    .done (resp) ->
      select = $('#roles', '.add-user-popup')
      select.empty()
      for role in resp.roles
        option = $('<option />').val(role.id).text(role.name)
        select.append option
    .fail ->
      console.log 'Error loading roles'

# Removes user
removeUser = ->
  item = $(this).parents('.student')
  $.ajax {
    url: '/removeUser',
    method: 'POST',
    data: {
      id: item.data('id')
    }
  }
    .done (resp) ->
      item.remove()
    .fail ->
      console.log "Error occured while deleting user"

$('.add-user').on 'submit', (event) ->
  event.preventDefault()

  removeValidationErrors $(this)
  valid = validate($('#username'), $('#password'), $('#firstName'), $('#lastName'))
  if not valid
    return

  $.ajax {
    url: $(this).attr('action'),
    method: 'POST',
    data: $(this).serialize()
  }
    .done (resp) ->
      list = $('.users-list')
      item = $('<div class="student clearfix">')
      console.log item
      removeBtn = $('<button class="remove-user">').text("Remove")

      removeBtn.on 'click', ->
        removeUser.call this

      item.data('id', resp.user.id)
      item.append $('<div class="username">').text resp.user.username
      item.append $('<div class="first-name">').text resp.user.firstName
      item.append $('<div class="last-name">').text resp.user.lastName
      item.append $('<div class="role">').text resp.user.role.name
      item.append $('<div class="remove">').append removeBtn
      list.append item
      $('.close-popup-btn').trigger 'click'
    .fail ->
      console.log "Error occured while saving user"

$('.remove-user').on 'click', (event) ->
  removeUser.call this

# Quiz board page. Start quiz button (Admin). Sends start event to the server
$('.start-quiz-btn').on 'click', ->
  that = this
  socketIo.emit 'begin', null, ->
    $(that).hide()

# saveResults function sends ajax for saving results.
# Also it hides inputs, shows spans and calculates total
saveResults = (parent) ->
  editElement = $(parent).find 'input'
  if editElement.length is 0 then return
  participant = editElement.parents('.participant')
  textElement = editElement.siblings 'span'
  value = +editElement.val() || 0
  if not (value is +textElement.text())
    userId = participant.data 'id'
    step = editElement.parent().data 'step'
    $.ajax {
      url: '/saveResults',
      method: 'POST',
      data: {
        userId: userId,
        step: step,
        value: value
      }
    }
      .fail ->
        console.log 'Error occured while saving results'
  textElement.text value
  totalTextElement = participant.find '.sum'
  step1Mark = +participant.find('.step1-results').text()
  step2Mark = +participant.find('.step2-results').text()
  totalTextElement.text(step1Mark + step2Mark)
  editElement.remove()
  textElement.show()

# Common results. Save results when user clicks outside of the field with mark
$('.results-of-participants'). on 'click', (event) ->
  saveResults this
  
# Common results. Show input when user clicks on span with mark
$('.js-step-results').on 'click', (event) ->
  if this is event.target or $(event.target)[0] is $(this).find('span')[0]
    saveResults $(this).parents '.results-of-participants'
    textElement = $(this).find('span')
    textElement.hide()
    $(this).append $('<input type="text" />').val textElement.text()
  event.stopPropagation()

# Result sorting
$('.total-results').find('.js-sort').on 'click', (event) ->
  ascendingOrder = (a, b) ->
    sortColumnA = $(a).find('td')[taskNumber]
    sortColumnB = $(b).find('td')[taskNumber]
    +$(sortColumnA).find('.sort-item').text() - (+$(sortColumnB).find('.sort-item').text())

  descendingOrder = (a, b) ->
    sortColumnA = $(a).find('td')[taskNumber]
    sortColumnB = $(b).find('td')[taskNumber]
    +$(sortColumnB).find('.sort-item').text() - (+$(sortColumnA).find('.sort-item').text())

  taskNumber = +$(this).parent().data 'col'
  sorted = $(this).parent().data('sorted') || false 
  table = $(this).parents 'table'
  rows = table.find('tbody').find 'tr'

  if sorted
    rows.sort descendingOrder
    $(this).parent().data 'sorted', false
  else
    rows.sort ascendingOrder
    $(this).parent().data 'sorted', true

  table.find('tbody').empty().append rows

# Parse seconds according to the format (mm:ss)
parseTime = (time) ->
  minutes = parseInt time / 60
  if minutes < 10 then minutes = '0' + minutes
  seconds = parseInt time - minutes * 60
  if seconds < 10 then seconds = '0' + seconds
  minutes + ':' + seconds

# Event from the server. When user is ready to start quiz this function adds
# user to the list of ready users
socketIo.on 'add user', (user) ->
  participantsList = $('.participants-list').find 'tbody'
  participant = $('<tr class="participant" data-id=' + user.id + ' />')
  participant.append $('<td />').text(user.firstName + ' ' + user.lastName)
  participant.append $('<td />')
  participant.append $('<td />')
  participant.append $('<td />')
  participant.appendTo participantsList

# Event from the server. When user passes one test of the quiz this function is called
# and adds results to the list
socketIo.on 'test passed', (data) ->
  user = data.user
  participantsList = $('.participants-list').find 'tbody'
  participant = participantsList.find 'tr[data-id=' + user.id + ']'
  participant.css 'background-color', '#b2ff59'
  setTimeout( ->
    participant.css 'background-color', ''
  , 500)
  columns = participant.find 'td'
  task = $(columns[data.task])
  task.text parseTime(data.time) + ' / ' + data.selectorLength + ' symbols'

# Quiz results
