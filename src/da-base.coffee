_       = require('lodash')
path    = require('path')
fs      = require('fs')
Chained = require('./chained')


module.exports = do ->

  class DaBase

    @_defaults =
      dir   : './files'
      name  : 'db.json'
      file  : null
      json  : "{}"
      parse : JSON.parse

    @toAbsolute = (name, dir) ->
      dir  ?= Base._defaults.dir
      name  =
        if /\.json$/.test(name)
        then name
        else name + '.json'
      path.resolve(path.join(dir, name))

    ###
      Only one source of json can be provided either the serialized version of an
      object provided as opts.json or a file which stores the json data.  If both
      are provided then this constructor will throw an Error.
    ###
    constructor: (opts = {}) ->
      if opts.file? and opts.json?
        throw new Error("Ambiguous json source provided both 'file' and 'json'")

      if opts.file? and fs.existsSync(opts.file)
        opts.json = fs.readFileSync(opts.file)

      opts       = _.defaults(opts, Base._defaults)

      @defaults  = opts
      @file     ?= opts.file or Base.toAbsolute(opts.name, @defaults.dir)
      @data      = opts.parse(opts.json)

    ###
      Saves the data to the json file as specified during construction.  If a file
      name was not provided it uses the default name (./db.json) (read: db.json
      in current dir).
    ###
    write : (file) ->
      fs.writeFileSync(file or @file, JSON.stringify(@data))

    ###
      Saves to the database (which is an object) the value provided with the
      name as the property key.  If a value was previously there it is simply
      over written.
    ###
    save : (name, val) ->
      val ?= @data[name] or []
      @data[name] = val
      new Chained({
        name: name
        data: val
        db: @
      })

    ###
      Loads the json saved in the given file.  Throws an Error
      if the file parameter is not provided or the file does not
      exist.

      opts.parse from the constructor is used to parse the text found in the given
      file, defaulted normally to JSON.parse.
    ###
    load : (file) ->
      if !file? and !@defaults.file?
        throw new Error("'file' was not provided")

      file  ?= @defaults.file

      if !fs.existsSync(file)
        throw new Error("file does not exist")

      json   = fs.readFileSync(file)
      @data  = @defaults.parse(json)


