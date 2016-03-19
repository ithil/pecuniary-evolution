fs = require 'fs'
Handlebars = require 'handlebars'

_templateCache = { }
loadTemplate = (name) ->
  return _templateCache[name] if _templateCache[name]?
  str = fs.readFileSync "#{__dirname}/../templates/#{name}.hbs", 'utf8'
  template = Handlebars.compile str
  _templateCache[name] = template
  return template

app._view = { }
app._view.loadTemplate = loadTemplate
views = { }
views.expenses = require './views/expensesView.js'

module.exports = {
  views
}
