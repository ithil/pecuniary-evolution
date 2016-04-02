$         = app.$
window    = app.window
document  = window.document
parseDate = app.utils.parseDate
view      = app.views.expenses
expenses  = app.databases.expenses
products  = app.databases.products

# Select all on focus
$('#addItemDialog .inputPrice').focus -> this.select()
$('#addItemDialog .inputDate').focus -> this.select()

# Parse date as soon as the input loses focus
$('#addItemDialog .inputDate').blur ->
  e = $(this)
  parsedDate = parseDate e.val()
  if parsedDate
    dateStr = "#{parsedDate.getDate()}/#{parsedDate.getMonth()+1}/#{parsedDate.getFullYear()}"
    e.val dateStr

$('#addItemDialog .inputPrice').blur ->
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
    { bottom: if visible then "-#{bottomPixels}px" else '-3px' },
    { duration: 250, complete: onComplete }
  )
$('#addItemButton').click toggleAddItemDialog
$('#addItemDialog').css 'bottom', "-#{$('#addItemDialog').height()+3}px"

clearAddItemDialog = () ->
  $('#addItemDialog input').val('')
  $('#addItemDialog .inputAmount').text('1')

submitItem = () ->
  des = $('#addItemDialog .inputDes').val()
  price = $('#addItemDialog .inputPrice').val()
  date = parseDate($('#addItemDialog .inputDate').val())
  amount = parseInt $('#addItemDialog .inputAmount').text()
  shop = $('#addItemDialog .inputShop').val()

  weightInput = $('#addItemDialog .inputWeight').val()
  weightRE = /([\d\.]+)\s*([a-zA-z]*)/g
  weightMatch = weightRE.exec weightInput
  if weightMatch
    weight = { }
    [__, weight.amount, weight.unit] = weightMatch
    unless weight.unit
      weight.unit = 'g'

  tagsInput = $('#addItemDialog .inputTags').val()
  if tagsInput
    tags = tagsInput.match(/[^,]+/g).map (i) -> i.trim()

  return false unless des and price and date # Abort if one of the values is missing
  expenses.addItem({
    description: des
    price: { amount: parseFloat(price), currency: 'EUR' }
    date: date
    amount: if amount > 1 then amount else undefined
    shop: shop
    weight: weight
    tags: tags
  }, ->
    view.loadItems()
  )
  clearAddItemDialog()

listener = new window.keypress.Listener $('#addItemDialog')
listener.simple_combo 'shift enter', -> submitItem()
listener.simple_combo 'ctrl a', -> $('#inputAmount').text (__, str) -> parseInt(str)+1
listener.simple_combo 'ctrl x', -> $('#inputAmount').text (__, str) -> parseInt(str)-1

$('.expenses tbody').on 'click', '.delete', ->
  id = $(this).parent().data 'id'
  expenses.deleteItem id, ->
    view.loadItems()

$('#addItemDialog .inputDes').autocomplete
  source: (input, callback) ->
    query = input.term
    products.getProducts query, (docs) ->
      items = [ ] # Array to contain all the suggestion entries
      docs.forEach (d) ->
        item = { }
        item.value = d.description
        item.id = d._id
        item.price = d.price
        item.shop = d.shop
        item.tags = d.tags
        # ^ That's super ugly, I know
        items.push item
      callback items
  select: (event, ui) ->
    item = ui.item
    $('#addItemDialog .inputPrice').val item.price.amount
    $('#addItemDialog .inputShop').val item.shop
    $('#addItemDialog .inputTags').val item.tags.join ', '
