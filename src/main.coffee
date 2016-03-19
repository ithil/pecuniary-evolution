global.app = {
  $:      $
  gui:    require 'nw.gui'
  window: window
}

global.app.utils      = require './lib/utils.js'
global.app.database   = require './lib/database.js'
global.app.productsDb = require './lib/productsDb.js'
global.app.expensesDb = require './lib/expensesDb.js'
global.app.view       = require './lib/view.js'
global.app.views      = global.app.view.views
global.app.controller = require './lib/controller.js'
