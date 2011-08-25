path = require 'path'
Application = require './lib/application'

if not global.Caboose?
  global.Caboose = {
    root: process.cwd()
    env: process.env.caboose_env ? 'development',
    app: new Application()
  }

exports.cli = require './lib/cli'
# 
# exports.Model = require './lib/model/model'

# exports.test = (run_path, options) ->
#   vows = require 'vows'
#   create_and_initialize_app options, (app) ->
#     if options._.length > 0
#       require path.join(app.paths.test, name) for name in options._
#       vows.suites[0].run {}, -> process.exit()
# 
# exports.run = (run_path, options) ->
#   return console.log 'USAGE: caboose run script_filename' if options._.length isnt 1
#   return console.log "ERROR: Could not find file #{options._[0]}" unless path.existsSync options._[0]
#   create_and_initialize_app options, (app) ->
#     require options._[0]
