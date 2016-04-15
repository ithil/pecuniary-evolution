$           = app.$
window      = app.window
document    = window.document
parseDate   = app.utils.parseDate
formatDate  = app.utils.formatDate
formatPrice = app.utils.formatPrice
view        = app.views.expenses
expenses    = app.databases.expenses
products    = app.databases.products

# Initialize all relevant jQuery objects
$addItemButton = $('#addItemButton')
$addItemDialog = $('#addItemDialog')
$inputDes        = $addItemDialog.find '.inputDes'
$inputPrice      = $addItemDialog.find '.inputPrice'
$inputDate       = $addItemDialog.find '.inputDate'
$inputAmount     = $addItemDialog.find '.inputAmount'
$inputWeight     = $addItemDialog.find '.inputWeight'
$inputShop       = $addItemDialog.find '.inputShop'
$inputTags       = $addItemDialog.find '.inputTags'
$_id             = $addItemDialog.find '.id'
$_productId      = $addItemDialog.find '.productId'
$_thingId        = $addItemDialog.find '.thingId'
$_pricePerWeight = $addItemDialog.find '.pricePerWeight'

# Select all on focus
$inputPrice.focus -> this.select()
$inputDate.focus -> this.select()

# Parse date as soon as the input loses focus
$inputDate.blur ->
  e = $(this)
  parsedDate = parseDate e.val()
  if parsedDate
    dateStr = "#{parsedDate.getDate()}/#{parsedDate.getMonth()+1}/#{parsedDate.getFullYear()}"
    e.val dateStr

$inputPrice.blur ->
  e = $(this)
  val = parseFloat e.val()
  unless isNaN val
    e.val val.toFixed 2

$inputAmount.click -> $(this).attr('contenteditable', 'true').focus()
$inputAmount.blur -> $(this).attr('contenteditable', 'false')

toggleAddItemDialog = (show) ->
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
$addItemButton.click -> toggleAddItemDialog()
$addItemDialog.css 'bottom', "-#{$addItemDialog.outerHeight()}px"

clearAddItemDialog = () ->
  $addItemDialog.find('input:not(.inputDate)').val('')
  $inputAmount.text('1')
  $addItemDialog.removeClass 'edit'
  $_pricePerWeight.removeData()
  $inputPrice.attr 'placeholder', 'Price'
  # Jump back to Description field
  $inputDes.focus()

submitItem = () ->
  des = $inputDes.val()
  price = $inputPrice.val()
  date = parseDate($inputDate.val())
  amount = parseInt $inputAmount.text()
  shop = $inputShop.val()
  productId = $_productId.val()
  thingId = $_thingId.val()

  weightInput = $inputWeight.val()
  weightRE = /([\d\.]+)\s*([a-zA-z]*)/g
  weightMatch = weightRE.exec weightInput
  if weightMatch
    weight = { }
    [__, weight.amount, weight.unit] = weightMatch
    unless weight.unit
      weight.unit = 'kg'

  tagsInput = $inputTags.val()
  if tagsInput
    tags = tagsInput.match(/[^,]+/g).map (i) -> i.trim()
  pricePerWeight = parseFloat($_pricePerWeight.data 'price')
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

  if $addItemDialog.hasClass 'edit'
    id = $_id.val()
    expenses.updateItem id, item, -> view.loadItems()
  else
    expenses.addItem item, -> view.loadItems()
  clearAddItemDialog()

editItem = (id) ->
  expenses.getItemById id, (item) ->
    $addItemDialog.addClass 'edit'
    toggleAddItemDialog(true)
    $_id.val item._id
    $_productId.val item.productId
    $_thingId.val item.thingId
    $inputDes.val item.description
    $inputAmount.text item.amount or 1
    $inputPrice.val item.price.amount.toFixed 2
    $inputDate.val formatDate item.date
    $inputWeight.val if item.weight then item.weight.amount+item.weight.unit else ''
    $inputShop.val item.shop
    $inputTags.val if item.tags then item.tags.join ', ' else ''

$('.expenses tbody').on 'dblclick', '.item', ->
  id = $(this).data 'id'
  editItem id

listener = new window.keypress.Listener $addItemDialog
listener.simple_combo 'shift enter', -> submitItem()
listener.simple_combo 'escape', -> clearAddItemDialog(); toggleAddItemDialog(false)
listener.simple_combo 'ctrl a', -> $inputAmount.text (__, str) -> parseInt(str)+1
listener.simple_combo 'ctrl x', -> $inputAmount.text (__, str) -> parseInt(str)-1

$('.expenses tbody').on 'click', '.delete', ->
  id = $(this).parent().data 'id'
  expenses.deleteItem id, ->
    view.loadItems()

$inputDes.autocomplete
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
    $_productId.val item.productId
    if item.pricePerWeight
      $_pricePerWeight.data 'price', item.price.amount
      $_pricePerWeight.data 'perWeight', item.perWeight
      $inputWeight.focus()
    else
      $inputPrice.val item.price?.amount
    $inputShop.val item.shop
    $inputTags.val item.tags.join ', '

$inputWeight.blur ->
  pricePerWeight = parseFloat($_pricePerWeight.data 'price')
  if pricePerWeight?
    weight = parseFloat $inputWeight.val()
    price = formatPrice({amount: weight * pricePerWeight})
    $inputPrice.attr 'placeholder', price
