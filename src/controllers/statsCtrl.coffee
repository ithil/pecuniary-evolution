$        = app.$
window   = app.window
document = window.document
view     = app.views.stats
expenses = app.databases.expenses
moment   = require 'moment'
parseDate = app.utils.parseDate
formatPrice = app.utils.formatPrice

# Initialize all relevant jQuery objects
$statsTab = $('#stats-tab')
$inputs   = $statsTab.find '.inputs'
$dateFrom = $inputs.find '[name="dateFrom"]'
$dateTo   = $inputs.find '[name="dateTo"]'
$tag      = $inputs.find '[name="tag"]'
$goButton = $inputs.find 'button.go'
$sum      = $statsTab.find '.sum'

$(document).ready ->
  go = ->
    dateFrom = parseDate($dateFrom.val())
    dateTo   = parseDate($dateTo.val())
    return unless dateFrom? and dateTo?
    query    = {date: {$gte: dateFrom, $lte: dateTo}}
    tag      = $tag.val()
    if tag then query.tags = tag
    expenses.raw.find query, (err, items) ->
      throw err if err
      sum = 0
      for i in items
        sum += i.price.amount
      $sum.text formatPrice {amount: sum, currency: 'EUR'}

  $goButton.click -> go()
  inputsListener = new window.keypress.Listener $inputs
  inputsListener.simple_combo 'enter', -> go()

  $dateFrom.val moment().subtract(12, 'weeks').format 'DD/MM/YYYY'
  $dateTo.val moment().format 'DD/MM/YYYY'
