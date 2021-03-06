$ = app.$
products = app.databases.products
loadTemplate = app._view.loadTemplate
formatPrice = app.utils.formatPrice

class ProductsTable
  constructor: (container) ->
    template = loadTemplate 'products/table'
    @table = $(template())
    @head = @table.find 'thead'
    @body = @table.find 'tbody'
    $(container).append @table

  addProduct: (product) ->
    template = loadTemplate 'products/table-product'
    row = $(template(
      description: product.description
      price: formatPrice product.price
      shop: product.shop
    ))
    row.data 'id', product._id
    @table.find('#noProducts').hide()
    @body.append row

  addProducts: (arr) ->
    for p in arr
      @addProduct p

  clearTable: ->
    @body.empty()

$('<button>Add product</button>').attr(id:'addProductButton', class:'addButton').appendTo '#products-tab'
APDtemplate = $ loadTemplate('products/add-dialog')()
APDtemplate.appendTo '#products-tab'

productsTable = new ProductsTable $('#products-tab')
loadProducts = ->
  products.getProducts '', (products) ->
    productsTable.clearTable()
    if products
      productsTable.addProducts products
    else
      $('#noProducts').show()

$ ->
  loadProducts()

module.exports = {
  loadProducts
}
