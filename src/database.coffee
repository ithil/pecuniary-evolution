LinvoDB = require("linvodb3")
LinvoDB.defaults.store = { db: require("medeadown") }
require('mkdirp').sync "#{__dirname}/../db"
LinvoDB.dbPath = "#{__dirname}/../db"

module.exports = {
  LinvoDB
}
