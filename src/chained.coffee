_ = require('lodash')


module.exports = do ->

  UNKNOWN = 'unknown'

  class Chained
    constructor: (opts) ->
      opts ?= {}

      @data = opts.data or []
      @name = opts.name or UNKNOWN
      @db   = opts.db or UNKNOWN
      @opts = opts

    commit  : (ar) -> @db.save(@name, ar or @data)
    write   : (file) ->
      @db.write(file)
      @

  for k,v of _.prototype
    Chained::[k] = do (k,v) -> (args...) ->
      if args.length is 0
        a = _.chain(@data)[k]()
      else if args.length > 0
        a = _.chain(@data)[k](args...)

      isChainable = _.has(a, '__chain__')

      if isChainable
        opts = _.defaults({}, { data: a.value() }, @opts)
        new Chained(opts)
      else
        a

  Chained