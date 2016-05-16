LinvoDB = app._database.LinvoDB
expenses = new LinvoDB 'expenses', {  }
moment = require 'moment'

raw = expenses

getAllExpenses = (callback) ->
  expenses.find({ }).sort({date: -1}).exec (err, items) ->
    throw err if err
    if items.length > 0
      callback items
    else
      callback false

getItemById = (id, callback) ->
  expenses.findOne _id: id, (err, item) ->
    throw err if err
    if item?
      callback item
    else
      callback false

getExpensesInDateRange = (from, to, callback) ->
  to = moment(to).add(1, 'day').toDate()
  expenses.find date: {$gte: from, $lte: to}, (err, items) ->
    throw err if err
    if items.length > 0
      callback items
    else
      callback false

addItem = (item, callback) ->
  expenses.save item, callback

updateItem = (id, changes, callback) ->
  expenses.update { _id: id }, { $set: changes }, callback

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
  getItemById
  getExpensesInDateRange
  raw
}
