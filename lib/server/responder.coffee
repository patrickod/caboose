ejs = require 'ejs'
path = require 'path'
ViewFactory = require '../view/view_factory'

class Responder
  constructor: (@req, @res, @next) ->
    @_renderers = {
      html: (controller, data, options) =>
        html = @render_html controller, data, options
        @res.contentType 'text/html'
        @res.send html, 200
      json: (controller, data, options) =>
        @res.contentType 'application/json'
        @res.send data, 200
    }

  render_html: (controller, data, options) ->
    http = Caboose.app.config.http
    locals = {
      server: {
        base_url: "http://#{http.host}#{(if http.port is 80 then '' else ':' + http.port)}"
      }
    }
    locals[k] = v for k, v of data

    # layoutFactory = global.registry.get "#layout_view"
    # viewFactory = global.registry.get "#{spec.controller}##{spec.action}_view"
    # viewFactory = global.registry.get
    view_factory = ViewFactory.compile path.join(Caboose.path.views, controller._short_name, "#{controller._view}.html.ejs")
    layout_factory = ViewFactory.compile path.join(Caboose.path.views, 'layout.html.ejs')

    if view_factory?
      view = view_factory.create()
      html = ejs.render view.html.template, {
        locals: locals
        filename: view.html.filename
      }
      if (not options? or not options.layout? or not options.layout is false) and layout_factory?
        layout = layout_factory.create()
        locals.yield = -> html
        layoutHtml = ejs.render layout.html.template, {
          locals: locals
          filename: layout.html.filename
        }
        html = layoutHtml
    html

  set_headers: (options) ->
    set_header = (k, v) => @res.header(k, v)
    if options?.headers?
      set_header k, v for k, v of options.headers

  render: (controller, data, options) ->
    format = @req.params.format ? 'html'
    renderer = @_renderers[format]
    @set_headers options
    @res.send 404 unless renderer?
    try
      renderer controller, data, options
    catch err
      console.dir err.stack
      @next err
    
    # return res.send 404 if not @view?.htmlTemplate?
    
  unauthorized: (options) ->
    @set_headers options
    @res.send 401
      
  redirect_to: (url, options) ->
    @set_headers options
    @res.redirect url

module.exports = Responder