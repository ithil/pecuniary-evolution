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

toggleAddProductDialog = ->
  $addProductDialog = $('#addProductDialog')
  visible = $addProductDialog.is ':visible'
  $addProductDialog.show() if not visible
  onComplete = ->
    $addProductDialog.hide() if visible
  bottomPixels = $addProductDialog.height()+3
  $addProductDialog.animate(
    { bottom: if visible then "-#{bottomPixels}px" else '-3px' },
    { duration: 250, complete: onComplete }
  )
$('#addProductButton').click toggleAddProductDialog
$('#addProductDialog').css 'bottom', "-#{$('#addProductDialog').height()+3}px"

clearAddProductDialog = () ->
  $('#addProductDialog input').val('')
  $('#addProductDialog .inputAmount').text('1')

submitProduct = () ->
  des = $('#addProductDialog .inputDes').val()
  price = $('#addProductDialog .inputPrice').val()
  shop = $('#addProductDialog .inputShop').val()

  tagsInput = $('#addProductDialog .inputTags').val()
  if tagsInput
    tags = tagsInput.match(/[^,]+/g).map (i) -> i.trim()

  return false unless des
  products.addProduct({
    description: des
    price: if price then { amount: parseFloat(price), currency: 'EUR' } else undefined
    shop: shop
    tags: tags
  }, ->
    view.loadProducts()
  )
  clearAddProductDialog()

listener = new window.keypress.Listener $('#addProductDialog')
listener.simple_combo 'shift enter', -> submitProduct()

$('.products tbody').on 'click', '.delete', ->
  id = $(this).parent().data 'id'
  products.deleteProduct id, ->
    view.loadProducts()
