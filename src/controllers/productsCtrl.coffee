$         = app.$
window    = app.window
document  = window.document
view      = app.views.products
products  = app.databases.products
things    = app.databases.things

# Initialize all relevant jQuery objects
$addProductButton = $('#addProductButton')
$addProductDialog = $('#addProductDialog')
$inputDes        = $addProductDialog.find '.inputDes'
$inputPrice      = $addProductDialog.find '.inputPrice'
$inputShop       = $addProductDialog.find '.inputShop'
$inputThing      = $addProductDialog.find '.inputThing'
$pricePerWeight  = $addProductDialog.find 'input[name="pricePerWeight"]'
$inputPerWeight  = $addProductDialog.find '.inputPerWeight'
$inputTags       = $addProductDialog.find '.inputTags'
$_id             = $addProductDialog.find '.id'
$_thingId        = $addProductDialog.find '.thingId'

# Select all on focus
$inputPrice.focus -> this.select()

$inputPrice.blur ->
  e = $(this)
  val = parseFloat e.val()
  unless isNaN val
    e.val val.toFixed 2

toggleAddProductDialog = (show) ->
  visible = $addProductDialog.is ':visible'
  if show? and show and visible then return
  if show? and not show and not visible then return
  $addProductDialog.show() if not visible
  onComplete = ->
    $addProductDialog.hide() if visible
  bottomPixels = $addProductDialog.outerHeight()
  $addProductDialog.animate(
    { bottom: if visible then "-#{bottomPixels}px" else "-#{$addProductDialog.css 'border-bottom-width'}" },
    { duration: 250, complete: onComplete }
  )
$addProductButton.click -> toggleAddProductDialog()
$addProductDialog.css 'bottom', "-#{$addProductDialog.outerHeight()}px"

clearAddProductDialog = () ->
  $addProductDialog.find('input').val('')
  $addProductDialog.removeClass 'edit'
  $pricePerWeight.prop 'checked', false
  # Jump back to Description field
  $inputDes.focus()

submitProduct = () ->
  des = $inputDes.val()
  price = $inputPrice.val()
  shop = $inputShop.val()
  pricePerWeight = $pricePerWeight.is ':checked'
  thingId = $_thingId.val()
  tagsInput = $inputTags.val()
  if tagsInput
    tags = tagsInput.match(/[^,]+/g).map (i) -> i.trim()

  return false unless des
  product = {}
  product.description = des
  if price then product.price = { amount: parseFloat(price), currency: 'EUR'}
  if shop.length > 0 then product.shop = shop
  product.pricePerWeight = pricePerWeight
  if tags? then product.tags = tags
  if thingId.length > 0 then product.thingId = thingId

  if $addProductDialog.hasClass 'edit'
    id = $_id.val()
    products.updateProduct id, product, -> view.loadProducts()
  else
    products.addProduct product, -> view.loadProducts()
  clearAddProductDialog()

editProduct = (id) ->
  products.getProductById id, (product) ->
    $addProductDialog.addClass 'edit'
    toggleAddProductDialog(true)
    $_id.val product._id
    $_thingId.val product.thingId
    if product.thingId
      things.getThingById product.thingId, (thing) ->
        $inputThing.val thing.description
    $inputDes.val product.description
    $inputPrice.val product.price.amount.toFixed 2
    $inputShop.val product.shop
    $pricePerWeight.prop 'checked', product.pricePerWeight or false
    $inputTags.val if product.tags then product.tags.join ', ' else ''

$('.products tbody').on 'dblclick', '.product', ->
  id = $(this).data 'id'
  editProduct id

listener = new window.keypress.Listener $addProductDialog
listener.simple_combo 'shift enter', -> submitProduct()
listener.simple_combo 'escape', -> clearAddProductDialog(); toggleAddProductDialog(false)

$('.products tbody').on 'click', '.delete', ->
  id = $(this).parent().data 'id'
  products.deleteProduct id, ->
    view.loadProducts()

$inputThing.autocomplete
  source: (input, callback) ->
    query = input.term
    things.getThings query, (docs) ->
      items = [ ] # Array to contain all the suggestion entries
      docs.forEach (d) ->
        item = { }
        item.value = d.description
        item.thingId = d._id
        item.tags = d.tags
        items.push item
      callback items
  select: (event, ui) ->
    item = ui.item
    $_thingId.val item.thingId
    $inputTags.val item.tags.join ', '
