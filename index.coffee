path = require 'path'
require './lib/registry'
Application = require './lib/application'

exports.Model = require './lib/model/model'
exports.start = (options) ->
  app = new Application()
  app.paths = require('./lib/paths').get('./app')

  # read config
  config = {}
  applicationConfig = require path.join app.paths.config, 'application'
  applicationConfig config if applicationConfig?

  global.app = app
  app.initialize config
  app.listen()
  console.log "Listening on port #{app.address().port}"