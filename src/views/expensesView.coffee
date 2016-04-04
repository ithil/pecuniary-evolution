$ = app.$
expenses = app.databases.expenses
loadTemplate = app._view.loadTemplate
formatPrice = app.utils.formatPrice
weekdays = app.utils.shortWeekdays

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
      price: formatPrice item.price
      total_price: formatPrice item.price, item.amount
    ))
    row.data 'id', item._id
    row.find('.price').attr 'title', "#{item.amount}x #{formatPrice item.price}" if item.amount
    @table.find('#noItems').hide()
    @body.append row

  addItems: (arr) ->
    currentDate = undefined
    totalPrice = 0
    DStemplate = loadTemplate 'date-separator'
    for i in arr
      if not currentDate? or currentDate.toDateString() isnt i.date.toDateString()
        if lastDS?
          lastDS.find('.totalPrice').text formatPrice {amount: totalPrice, currency: 'EUR'}
        DS = $(DStemplate(date: i.date.toLocaleDateString('de-DE'), weekday: weekdays[i.date.getDay()]))
        @body.append DS
        totalPrice = 0
        lastDS = DS
      totalPrice += i.price.amount*(i.amount or 1)
      currentDate = i.date
      @addItem i
    # Do it one last time
    lastDS.find('.totalPrice').text formatPrice {amount: totalPrice, currency: 'EUR'}

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

$('<button>+</button>').attr(id:'addItemButton', class:'addButton').appendTo '#expenses-tab'
AIDtemplate = $ loadTemplate('add-item-dialog')()
AIDtemplate.appendTo '#expenses-tab'

$ ->
  $inputDes = $('#inputDes')
  ACTemplate = loadTemplate 'add-item-autocomplete'
  $inputDes.autocomplete('instance')?._renderItem = (ul, item) ->
    $(ACTemplate(
      description: item.value
      price: item.price?.amount.toFixed 2
      shop: item.shop
    )).appendTo ul
  $inputDes.autocomplete 'option', 'position', { my: 'left bottom', at: 'left top'}

module.exports = {
  loadItems
}
