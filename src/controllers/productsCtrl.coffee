$         = app.$
window    = app.window
document  = window.document
view      = app.views.products
products  = app.databases.products

# Select all on focus
$('#addProductDialog .inputPrice').focus -> this.select()

$('#addProductDialog .inputPrice').blur ->
  e = $(this)
  val = parseFloat e.val()
  unless isNaN val
    e.val val.toFixed 2

toggleAddProductDialog = (show) ->
  $addProductDialog = $('#addProductDialog')
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
$('#addProductButton').click -> toggleAddProductDialog()
$('#addProductDialog').css 'bottom', "-#{$('#addProductDialog').outerHeight()}px"

clearAddProductDialog = () ->
  $('#addProductDialog input').val('')
  $('#addProductDialog').removeClass 'edit'
  $('#addProductDialog .id').val('')
  $('#addProductDialog input[name="pricePerWeight"]').prop 'checked', false

submitProduct = () ->
  des = $('#addProductDialog .inputDes').val()
  price = $('#addProductDialog .inputPrice').val()
  shop = $('#addProductDialog .inputShop').val()
  pricePerWeight = $('#addProductDialog input[name="pricePerWeight"]').is ':checked'
  tagsInput = $('#addProductDialog .inputTags').val()
  if tagsInput
    tags = tagsInput.match(/[^,]+/g).map (i) -> i.trim()

  return false unless des
  product = {}
  product.description = des
  if price then product.price = { amount: parseFloat(price), currency: 'EUR'}
  if shop.length > 0 then product.shop = shop
  product.pricePerWeight = pricePerWeight
  if tags? then product.tags = tags
  if $('#addProductDialog').hasClass 'edit'
    id = $('#addProductDialog .id').val()
    products.updateProduct id, product, -> view.loadProducts()
  else
    products.addProduct product, -> view.loadProducts()
  clearAddProductDialog()

editProduct = (id) ->
  products.getProductById id, (product) ->
    $addProductDialog = $('#addProductDialog')
    $addProductDialog.addClass 'edit'
    toggleAddProductDialog(true)
    $addProductDialog.find('.id').val product._id
    $addProductDialog.find('.inputDes').val product.description
    $addProductDialog.find('.inputPrice').val product.price.amount.toFixed 2
    $addProductDialog.find('.inputShop').val product.shop
    $addProductDialog.find('input[name="pricePerWeight"]').prop 'checked', product.pricePerWeight or false
    $addProductDialog.find('.inputTags').val if product.tags then product.tags.join ', ' else ''

$('.products tbody').on 'dblclick', '.product', ->
  id = $(this).data 'id'
  editProduct id

listener = new window.keypress.Listener $('#addProductDialog')
listener.simple_combo 'shift enter', -> submitProduct()
listener.simple_combo 'escape', -> clearAddProductDialog(); toggleAddProductDialog(false)

$('.products tbody').on 'click', '.delete', ->
  id = $(this).parent().data 'id'
  products.deleteProduct id, ->
    view.loadProducts()
