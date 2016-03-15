LinvoDB = require("linvodb3")
LinvoDB.defaults.store = { db: require("medeadown") }
require('mkdirp').sync "#{__dirname}/../db"
LinvoDB.dbPath = "#{__dirname}/../db"

expenses = new LinvoDB "expenses", {  }

getAllExpenses = (callback) ->
  expenses.find({ }).sort({date: -1}).exec (err, items) ->
    throw err if err
    if items.length > 0
      callback items
    else
      callback false

addItem = (item, callback) ->
  expenses.save item, callback

updateItem = (id, changes, callback) ->
  expenses.update { _id: id }, { $set: changes }, ->
    callback()

deleteItem = (id, callback) ->
  expenses.findOne { _id: id }, (err, doc) ->
    doc.remove ->
      unless err
        callback true
      else
        callback false

module.exports = {
  getAllExpenses
  addItem
  updateItem
  deleteItem
}
