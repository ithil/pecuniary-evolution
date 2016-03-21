$        = app.$
window   = app.window
document = window.document
views    = app.views
gui      = app.gui

$ ->
  $('#loader').hide()
  views.expenses.loadItems()

# Global keyboard shortcuts
$(document).bind 'keydown', 'ctrl+d', -> gui.Window.get().showDevTools()

controllers = { }
controllers.expenses = require './controllers/expensesCtrl.js'

module.exports = {
  controllers
}
