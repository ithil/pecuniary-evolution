$           = app.$
window      = app.window
document    = window.document
parseDate   = app.utils.parseDate
formatDate  = app.utils.formatDate
formatPrice = app.utils.formatPrice
view        = app.views.expenses
expenses    = app.databases.expenses
products    = app.databases.products

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

$('#addItemDialog .inputAmount').click -> $(this).attr('contenteditable', 'true').focus()
$('#addItemDialog .inputAmount').blur -> $(this).attr 'contenteditable', 'false'

toggleAddItemDialog = (show) ->
  $addItemDialog = $('#addItemDialog')
  visible = $addItemDialog.is ':visible'
  if show? and show and visible then return
  if show? and not show and not visible then return
  $addItemDialog.show() if not visible
  onComplete = ->
    $addItemDialog.hide() if visible
  bottomPixels = $addItemDialog.outerHeight()
  $addItemDialog.animate(
    { bottom: if visible then "-#{bottomPixels}px" else "-#{$addItemDialog.css 'border-bottom-width'}" },
    { duration: 250, complete: onComplete }
  )
$('#addItemButton').click -> toggleAddItemDialog()
$('#addItemDialog').css 'bottom', "-#{$('#addItemDialog').outerHeight()}px"

clearAddItemDialog = () ->
  $('#addItemDialog input:not(.inputDate)').val('')
  $('#addItemDialog .inputAmount').text('1')
  $('#addItemDialog').removeClass 'edit'
  $('#addItemDialog .pricePerWeight').removeData()
  $('#addItemDialog .inputPrice').attr 'placeholder', 'Price'
  # Jump back to Description field
  $('#addItemDialog .inputDes').focus()

submitItem = () ->
  des = $('#addItemDialog .inputDes').val()
  price = $('#addItemDialog .inputPrice').val()
  date = parseDate($('#addItemDialog .inputDate').val())
  amount = parseInt $('#addItemDialog .inputAmount').text()
  shop = $('#addItemDialog .inputShop').val()
  productId = $('#addItemDialog .productId').val()
  thingId = $('#addItemDialog .thingId').val()

  weightInput = $('#addItemDialog .inputWeight').val()
  weightRE = /([\d\.]+)\s*([a-zA-z]*)/g
  weightMatch = weightRE.exec weightInput
  if weightMatch
    weight = { }
    [__, weight.amount, weight.unit] = weightMatch
    unless weight.unit
      weight.unit = 'kg'

  tagsInput = $('#addItemDialog .inputTags').val()
  if tagsInput
    tags = tagsInput.match(/[^,]+/g).map (i) -> i.trim()
  pricePerWeight = parseFloat($('#addItemDialog .pricePerWeight').data 'price')
  if not price and pricePerWeight and weight
    price = weight.amount * pricePerWeight
  return false unless des and price and date # Abort if one of the values is missing
  item = {}
  item.description = des
  item.price = { amount: parseFloat(price), currency: 'EUR' }
  item.date = date
  if amount > 1 then item.amount = amount
  if shop.length > 0 then item.shop = shop
  if weight? then item.weight = weight
  if tags? then item.tags = tags
  if productId.length > 0 then item.productId = productId
  if thingId.length > 0 then item.thingId = thingId

  if $('#addItemDialog').hasClass 'edit'
    id = $('#addItemDialog .id').val()
    expenses.updateItem id, item, -> view.loadItems()
  else
    expenses.addItem item, -> view.loadItems()
  clearAddItemDialog()

editItem = (id) ->
  expenses.getItemById id, (item) ->
    $addItemDialog = $('#addItemDialog')
    $addItemDialog.addClass 'edit'
    toggleAddItemDialog(true)
    $addItemDialog.find('.id').val item._id
    $addItemDialog.find('.inputDes').val item.description
    $addItemDialog.find('.inputAmount').text item.amount or 1
    $addItemDialog.find('.inputPrice').val item.price.amount.toFixed 2
    $addItemDialog.find('.inputDate').val formatDate item.date
    $addItemDialog.find('.inputWeight').val if item.weight then item.weight.amount+item.weight.unit else ''
    $addItemDialog.find('.inputShop').val item.shop
    $addItemDialog.find('.inputTags').val if item.tags then item.tags.join ', ' else ''
    $addItemDialog.find('.productId').val item.productId
    $addItemDialog.find('.thingId').val item.thingId

$('.expenses tbody').on 'dblclick', '.item', ->
  id = $(this).data 'id'
  editItem id

listener = new window.keypress.Listener $('#addItemDialog')
listener.simple_combo 'shift enter', -> submitItem()
listener.simple_combo 'escape', -> clearAddItemDialog(); toggleAddItemDialog(false)
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
        item.productId = d._id
        item.price = d.price
        item.shop = d.shop
        item.tags = d.tags
        item.pricePerWeight = d.pricePerWeight
        # ^ That's super ugly, I know
        items.push item
      callback items
  select: (event, ui) ->
    item = ui.item
    $('#addItemDialog .productId').val item.productId
    if item.pricePerWeight
      $('#addItemDialog .pricePerWeight').data 'price', item.price.amount
      $('#addItemDialog .pricePerWeight').data 'perWeight', item.perWeight
      $('#addItemDialog .inputWeight').focus()
    else
      $('#addItemDialog .inputPrice').val item.price.amount
    $('#addItemDialog .inputShop').val item.shop
    $('#addItemDialog .inputTags').val item.tags.join ', '

$('#addItemDialog .inputWeight').blur ->
  pricePerWeight = parseFloat($('#addItemDialog .pricePerWeight').data 'price')
  if pricePerWeight?
    weight = parseFloat $('#addItemDialog .inputWeight').val()
    price = formatPrice({amount: weight * pricePerWeight})
    $('#addItemDialog .inputPrice').attr 'placeholder', price
