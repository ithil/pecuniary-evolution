$        = app.$
window   = app.window
document = window.document
views    = app.views
gui      = app.gui

$ ->
  $('#loader').hide()
  views.expenses.loadItems()

# Global keyboard shortcuts
globalListener = new window.keypress.Listener()
globalListener.simple_combo 'ctrl d', -> gui.Window.get().showDevTools()
globalListener.sequence_combo 'ctrl s e', -> $('a[href="#expenses-tab"]').click()
globalListener.sequence_combo 'ctrl s p', -> $('a[href="#products-tab"]').click()
globalListener.sequence_combo 'ctrl s t', -> $('a[href="#things-tab"]').click()

controllers = { }
controllers.expenses = require './controllers/expensesCtrl.js'
controllers.products = require './controllers/productsCtrl.js'
controllers.things = require './controllers/thingsCtrl.js'

module.exports = {
  controllers
}
