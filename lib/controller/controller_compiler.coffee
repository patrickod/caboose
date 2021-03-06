Path = require '../path'
Compiler = require '../compiler'
Builder = require './builder'

class ControllerCompiler extends Compiler
  precompile: ->
    matches = /class\W+([^\W]+)\W+extends\W+([^\W]*Controller)/.exec(@code)
    throw new Error 'Could not find a model defined' unless matches?
    @name = matches[1]
    @extends = matches[2]
    scope_var = "__scope_#{@name}__"
    @code = @code.replace(/class\W+([^\W]+)\W+extends\W+([^\W]*Controller)/, "class @#{@name} extends #{@extends}")
    
    indent = /\n([ \t]+)/.exec(@code)
    indent = if indent? then indent[1] else '  '
    text = /([ \t]*)class\W+([^\W]+)\W+extends\W+([^\W]*Controller)[^\n]*/.exec(@code)

    a = new RegExp("\n#{text[1]}[^ \t\n]").exec(@code.substr(text.index + text[0].length))
    if a?
      l = text.index + text[0].length + a.index
      @code = @code.substr(0, l) + "#{indent}#{scope_var} false\n" + @code.substr(l)

    text = text[0]
    @code = @code.replace(text, "#{text}\n#{indent}#{scope_var} true")
    
    @builder = new Builder(@name, @extends)
    
    @scope.Controller = class __CONTROLLER__
    @scope[scope_var] = (a) => @scope[scope_var] = a
    for k of @builder
      do (k) =>
        @scope[k] = (args...) =>
          throw new Error("#{k} is not defined") if @scope[scope_var] isnt true
          @builder[k](args...)
    
    while import_call = /^\W*import\W+('([^']+)'|"([^"]+)")/.exec(@code)
      import_object = Caboose.registry.get import_call[2]
      import_object = import_object.class if import_object.type is 'controller'
      @scope[import_call[2]] = import_object
      @code = @code.replace import_call[0], ''

    while require_call = /^\W*require\W+('([^']+)'|"([^"]+)")/.exec(@code)
      @code = @code.replace require_call[0], "#{require_call[2]} = require '#{require_call[2]}'"

    # @apply_scope_plugins 'models'
    # @apply_precompile_plugins 'models'

  postcompile: ->
    for method in Object.keys(@scope[@name]::)
      @builder.action method, @scope[@name]::[method]
    # @apply_postcompile_plugins 'models'
  
  respond: ->
    @response = @builder.build()
    
    # short_name = /\/([^\/.]+)\_controller.coffee$/.exec(@fullPath)[1]
    
    # @response = new ControllerFactory @name, short_name, @extends, @scope.class, @filters, @helpers
    # @apply_respond_plugins 'models'
    @response

  @compile = (file) ->
    file = new Path(file) unless Path.isPath(file)
    return null unless file.exists_sync()
    compiler = new ControllerCompiler()
    try
      compiler.compile_file file.path
    catch err
      console.log "Error trying to compile Controller for #{file.path}"
      console.error err.stack
      null
    
module.exports = ControllerCompiler
