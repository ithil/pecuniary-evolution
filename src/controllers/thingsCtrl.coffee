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
  bottomPixels = $addThingDialog.height()+3
  $addThingDialog.animate(
    { bottom: if visible then "-#{bottomPixels}px" else '-3px' },
    { duration: 250, complete: onComplete }
  )
$('#addThingButton').click toggleAddThingDialog
$('#addThingDialog').css 'bottom', "-#{$('#addThingDialog').height()+3}px"

clearAddThingDialog = () ->
  $('#addThingDialog input').val('')

submitThing = () ->
  des = $('#addThingDialog .inputDes').val()
  tagsInput = $('#addThingDialog .inputTags').val()
  if tagsInput
    tags = tagsInput.match(/[^,]+/g).map (i) -> i.trim()

  return false unless des
  things.addThing({
    description: des
    tags: tags
  }, ->
    view.loadThings()
  )
  clearAddThingDialog()

listener = new window.keypress.Listener $('#addThingDialog')
listener.simple_combo 'shift enter', -> submitThing()

$('.things tbody').on 'click', '.delete', ->
  id = $(this).parent().data 'id'
  things.deleteThing id, ->
    view.loadThings()
