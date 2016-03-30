$ = app.$
LinvoDB = app._database.LinvoDB

products = new LinvoDB 'products', {  }

getProducts = (query, callback) ->
  queryRE = new RegExp query, 'gi'
  products.find description: { $regex: queryRE }, (err, docs) ->
    throw err if err
    callback docs

addProduct = (product, callback) ->
  product ?= { }
  product.lastModified = new Date()
  products.save product, callback

updateProduct = (id, changes, callback) ->
  products.update { _id: id }, { $set: changes }, ->
    callback()

deleteProduct = (id, callback) ->
  products.findOne { _id: id }, (err, doc) ->
    doc.remove ->
      unless err
        callback true
      else
        callback false

module.exports = {
  getProducts
  addProduct
  updateProduct
  deleteProduct
  products
}