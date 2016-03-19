$         = app.$
gui       = app.gui
window    = app.window
document  = window.document
parseDate = app.utils.parseDate
view      = app.views.expenses
expenses  = app.databases.expenses
products  = app.databases.products

$ ->
  $('#loader').hide()
  view.loadItems()

# Keyboard shortcuts
$(document).bind 'keydown', 'ctrl+d', -> gui.Window.get().showDevTools()

# Select all on focus
$('#inputPrice').focus -> this.select()
$('#inputDate').focus -> this.select()

# Parse date as soon as the input loses focus
$('#inputDate').blur ->
  e = $(this)
  parsedDate = parseDate e.val()
  if parsedDate
    dateStr = "#{parsedDate.getDate()}/#{parsedDate.getMonth()+1}/#{parsedDate.getFullYear()}"
    e.val dateStr

$('#inputPrice').blur ->
  e = $(this)
  val = parseFloat e.val()
  unless isNaN val
    e.val val.toFixed 2

toggleAddItemDialog = ->
  addItemDialog = $('#addItemDialog')
  visible = addItemDialog.is ':visible'
  addItemDialog.show() if not visible
  onComplete = ->
    addItemDialog.hide() if visible
  bottomPixels = addItemDialog.height()+3
  addItemDialog.animate(
    { bottom: if visible then "-#{bottomPixels}px" else '0px' },
    { duration: 250, complete: onComplete }
  )
$('#addItemButton').click toggleAddItemDialog
toggleAddItemDialog()

clearAddItemDialog = () ->
  $('#addItemDialog input').val('')
  $('#inputAmount').text('1')

submitItem = () ->
  des = $('#inputDes').val()
  price = $('#inputPrice').val()
  date = parseDate($('#inputDate').val())
  amount = parseInt $('#inputAmount').text()
  location = $('#inputLocation').val()

  weightInput = $('#inputWeight').val()
  weightRE = /([\d\.]+)\s*([a-zA-z]*)/g
  weightMatch = weightRE.exec weightInput
  if weightMatch
    weight = { }
    [__, weight.amount, weight.unit] = weightMatch
    unless weight.unit
      weight.unit = 'g'

  tagsInput = $('#inputTags').val()
  if tagsInput
    tags = tagsInput.match(/[^,]+/g).map (i) -> i.trim()

  return false unless des and price and date # Abort if one of the values is missing
  expenses.addItem({
    description: des
    price: { amount: parseFloat(price), currency: 'EUR' }
    date: date
    amount: if amount > 1 then amount else undefined
    location: location
    weight: weight
    tags: tags
  }, ->
    view.loadItems()
  )
  clearAddItemDialog()

$('#inputDes, #inputPrice, #inputDate').bind 'keydown', 'return', ->
  submitItem()

$('.expenses tbody').on 'click', '.delete', ->
  id = $(this).parent().data 'id'
  expenses.deleteItem id, ->
    view.loadItems()

$('#inputDes').autocomplete
  source: (input, callback) ->
    query = input.term
    products.getProducts query, (docs) ->
      items = [ ] # Array to contain all the suggestion entries
      docs.forEach (d) ->
        item = { }
        item.value = d.description
        item.id = d._id
        item.price = d.price
        item.location = d.location
        item.tags = d.tags
        # ^ That's super ugly, I know
        items.push item
      callback items
  select: (event, ui) ->
    item = ui.item
    $('#inputPrice').val item.price.amount
    $('#inputLocation').val item.location
    $('#inputTags').val item.tags.join ', '
