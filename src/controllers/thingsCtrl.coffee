$         = app.$
window    = app.window
document  = window.document
view      = app.views.things
things    = app.databases.things

# Select all on focus
$('#addThingDialog .inputPrice').focus -> this.select()

toggleAddThingDialog = ->
  $addThingDialog = $('#addThingDialog')
  visible = $addThingDialog.is ':visible'
  $addThingDialog.show() if not visible
  onComplete = ->
    $addThingDialog.hide() if visible
  bottomPixels = $addThingDialog.outerHeight()
  $addThingDialog.animate(
    { bottom: if visible then "-#{bottomPixels}px" else "-#{$addThingDialog.css 'border-bottom-width'}" },
    { duration: 250, complete: onComplete }
  )
$('#addThingButton').click -> toggleAddThingDialog()
$('#addThingDialog').css 'bottom', "-#{$('#addThingDialog').outerHeight()}px"

clearAddThingDialog = () ->
  $('#addThingDialog input').val('')
  $('#addThingDialog').removeClass 'edit'
  # Jump back to Description field
  $('#addThingDialog .inputDes').focus()

submitThing = () ->
  des = $('#addThingDialog .inputDes').val()
  tagsInput = $('#addThingDialog .inputTags').val()
  if tagsInput
    tags = tagsInput.match(/[^,]+/g).map (i) -> i.trim()

  return false unless des
  thing = {}
  thing.description = des
  if tags? then thing.tags = tags
  if $('#addThingDialog').hasClass 'edit'
    id = $('#addThingDialog .id').val()
    things.updateThing id, thing, -> view.loadThings()
  else
    things.addThing thing, -> view.loadThings()
  clearAddThingDialog()

editThing = (id) ->
  things.getThingById id, (thing) ->
    $addThingDialog = $('#addThingDialog')
    $addThingDialog.addClass 'edit'
    toggleAddThingDialog(true)
    $addThingDialog.find('.id').val thing._id
    $addThingDialog.find('.inputDes').val thing.description
    $addThingDialog.find('.inputTags').val if thing.tags then thing.tags.join ', ' else ''

$('.things tbody').on 'dblclick', '.thing', ->
  id = $(this).data 'id'
  editThing id

listener = new window.keypress.Listener $('#addThingDialog')
listener.simple_combo 'shift enter', -> submitThing()
listener.simple_combo 'escape', -> clearAddThingDialog(); toggleAddThingDialog(false)

$('.things tbody').on 'click', '.delete', ->
  id = $(this).parent().data 'id'
  things.deleteThing id, ->
    view.loadThings()
