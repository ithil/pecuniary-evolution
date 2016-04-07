$ = app.$
things = app.databases.things
loadTemplate = app._view.loadTemplate

class ThingsTable
  constructor: (container) ->
    template = loadTemplate 'things/table'
    @table = $(template())
    @head = @table.find 'thead'
    @body = @table.find 'tbody'
    $(container).append @table

  addThing: (thing) ->
    template = loadTemplate 'things/table-thing'
    row = $(template(
      description: thing.description
      price: thing.price?.amount.toFixed 2
      shop: thing.shop
    ))
    row.data 'id', thing._id
    @table.find('#noThings').hide()
    @body.append row

  addThings: (arr) ->
    for p in arr
      @addThing p

  clearTable: ->
    @body.empty()

$('<button>Add thing</button>').attr(id:'addThingButton', class:'addButton').appendTo '#things-tab'
ATDtemplate = $ loadTemplate('things/add-dialog')()
ATDtemplate.appendTo '#things-tab'

thingsTable = new ThingsTable $('#things-tab')
loadThings = ->
  things.getThings '', (things) ->
    thingsTable.clearTable()
    if things
      thingsTable.addThings things
    else
      $('#noThings').show()

$ ->
  loadThings()

module.exports = {
  loadThings
}
