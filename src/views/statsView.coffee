$ = app.$
loadTemplate = app._view.loadTemplate
expenses = app.databases.expenses
moment = require 'moment'

statsTemplate = $ loadTemplate('stats/tab')()
statsTemplate.appendTo '#stats-tab'

module.exports = {
}
