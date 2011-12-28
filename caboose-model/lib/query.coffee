module.exports = class Query
  constructor: (@model, @query) ->
    @query ?= {}
    @query._id = new Query.ObjectID(@query._id) if @query._id? and typeof @query._id is 'string'
    @options = {}

  skip: (count) ->
    @options.skip = count
    this

  limit: (count) ->
    @options.limit = count
    this

  sort: (fields) ->
    @options.sort = fields
    this
  
  fields: (fields) ->
    @options.fields = fields
    this

  each: (callback) ->
    @model._ensure_collection (c) =>
      c.find(@query, @options).each (err, item) =>
        return callback err if err?
        callback null, new @model(item)

  array: (callback) ->
    @model._ensure_collection (c) =>
      c.find(@query, @options).toArray (err, items) =>
        return callback err if err?
        if items?
          items[x] = new @model(items[x]) for x in [0...items.length]
        callback null, items

  first: (callback) ->
    @model._ensure_collection (c) =>
      @options.limit = 1
      c.find(@query, @options).nextObject (err, item) =>
        return callback err if err?
        callback null, (if item? then new @model(item) else null)
  
  count: (callback) ->
    @model._ensure_collection (c) =>
      c.count @query, callback

  distinct: (key, callback) ->
    @model._ensure_collection (c) =>
      c.distinct key, @query, callback
