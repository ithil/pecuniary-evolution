$ = app.$
LinvoDB = app._database.LinvoDB

things = new LinvoDB 'things', {  }

getThings = (query, callback) ->
  queryRE = new RegExp query, 'gi'
  things.find description: { $regex: queryRE }, (err, docs) ->
    throw err if err
    callback docs

getThingById = (id, callback) ->
  things.findOne _id: id, (err, thing) ->
    throw err if err
    if thing?
      callback thing
    else
      callback false

addThing = (thing, callback) ->
  thing ?= { }
  thing.lastModified = new Date()
  things.save thing, callback

updateThing = (id, changes, callback) ->
  things.update { _id: id }, { $set: changes }, callback

deleteThing = (id, callback) ->
  things.findOne { _id: id }, (err, doc) ->
    doc.remove ->
      unless err
        callback true
      else
        callback false

module.exports = {
  getThings
  getThingById
  addThing
  updateThing
  deleteThing
  things
}
