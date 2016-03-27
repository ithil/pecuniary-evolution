$ = app.$
expenses = app.databases.expenses
loadTemplate = app._view.loadTemplate

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
      price: item.price?.amount.toFixed 2
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

expenseTable = new ExpenseTable $('#expenses-tab')
loadItems = ->
  expenses.getAllExpenses (items) ->
    expenseTable.clearTable()
    if items
      expenseTable.addItems items
    else
      $('#noItems').show()
$ ->
  $inputDes = $('#inputDes')
  template = loadTemplate 'add-item-autocomplete'
  $inputDes.autocomplete('instance')?._renderItem = (ul, item) ->
    $(template(
      description: item.value
      price: item.price?.amount.toFixed 2
      location: item.location
    )).appendTo ul
  $inputDes.autocomplete 'option', 'position', { my: 'left bottom', at: 'left top'}

module.exports = {
  loadItems
}
