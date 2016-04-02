fs = require 'fs'
Handlebars = require 'handlebars'
$ = app.$

_templateCache = { }
loadTemplate = (name) ->
  return _templateCache[name] if _templateCache[name]?
  str = fs.readFileSync "#{__dirname}/../templates/#{name}.hbs", 'utf8'
  template = Handlebars.compile str
  _templateCache[name] = template
  return template

# Tabs
addTab = (name, id) ->
  tabNav = $ "<li><a href='##{id}-tab'>#{name}</a></li>"
  tabNav.appendTo '#tabs ul'
  tabContent = $ "<div id='#{id}-tab' class='tab'></div>"
  tabContent.appendTo '#tabs'
  $('#tabs').tabs 'refresh'

$tabs = $ '#tabs'
$tabs.tabs()
addTab 'Expenses', 'expenses'
addTab 'Products', 'products'
addTab 'Things', 'things'
$tabs.tabs 'option', 'active', 0
$tabs.show()

app._view = { }
app._view.loadTemplate = loadTemplate
views = { }
views.expenses = require './views/expensesView.js'
views.products = require './views/productsView.js'
views.things = require './views/thingsView.js'

module.exports = {
  views
}
