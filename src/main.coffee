global.app = {
  $:      $
  gui:    require 'nw.gui'
  window: window
}

global.app.utils       = require './lib/utils.js'
global.app.database    = require './lib/database.js'
global.app.databases   = global.app.database.databases
global.app.view        = require './lib/view.js'
global.app.views       = global.app.view.views
global.app.controller  = require './lib/controller.js'
global.app.controllers = global.app.controller.controllers
