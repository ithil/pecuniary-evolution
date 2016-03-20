LinvoDB = require 'linvodb3'
LinvoDB.defaults.store = { db: require 'medeadown' }
require('mkdirp').sync "#{__dirname}/../db"
LinvoDB.dbPath = "#{__dirname}/../db"

app._database = { }
app._database.LinvoDB = LinvoDB
databases = { }
databases.expenses = require './databases/expensesDb.js'
databases.products = require './databases/productsDb.js'

module.exports = {
  databases
}
