fs = require 'fs'
Handlebars = require 'handlebars'
$ = app.$
expenses = app.expensesDb

_templateCache = { }
loadTemplate = (name) ->
  return _templateCache[name] if _templateCache[name]?
  str = fs.readFileSync "#{__dirname}/../templates/#{name}.hbs", 'utf8'
  template = Handlebars.compile str
  _templateCache[name] = template
  return template

class ExpenseTable
  constructor: (container) ->
    template = loadTemplate 'expense-table'
    @table = $(template())
    @head = @table.find 'thead'
    @body = @table.find 'tbody'
    $(container).append @table

  addItem: (item) ->
    template = loadTemplate 'expense-table-item'
    row = $(template(
      description: item.description
      amount: item.amount
      total_price: (item.price?.amount*(item.amount or 1)).toFixed 2
      date: item.date?.toLocaleDateString 'de-DE'
    ))
    row.data 'id', item._id
    row.find('.price').attr 'title', "#{item.amount}x #{item.price.amount.toFixed 2}" if item.amount
    @table.find('#noItems').hide()
    @body.append row

  addItems: (arr) ->
    for i in arr
      @addItem i

  clearTable: ->
    @body.empty()

expenseTable = new ExpenseTable $('#table')
loadItems = ->
  expenses.getAllExpenses (items) ->
    expenseTable.clearTable()
    if items
      expenseTable.addItems items
    else
      $('#noItems').show()

module.exports = {
  expenseTable
  loadItems
}
