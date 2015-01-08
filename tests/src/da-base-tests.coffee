fs      = require("fs")
path    = require("path")
Base    = require("../../src/da-base")
Chained = require('../../src/chained')

rm = (file) ->
  if fs.existsSync(file)
    fs.unlinkSync(file)

join = (file) ->
  path.join(Base._defaults.dir, file)

exists = (file) ->
  fs.existsSync(file)


describe 'da-base-tests =>', ->

  describe 'chained write =>', ->

    name = 'write-1.json'

    beforeEach -> rm(join name)
    afterEach  -> rm(join name)

    it 'should write values and read those values', ->
      db = new Base({ name: name })
      vals = (n for n in [1..21])
      db.save("nodes", vals)
        .map((a) -> a * 10)
        .commit()
        .write()

      expect(exists(join name)).to.be.true
      expect(db.data.nodes).to.have.length(vals.length)

      db = new Base({ file: join(name) })

      expect(db.data.nodes).to.exist
      expect(db.data.nodes).to.have.length(vals.length)

  describe 'chained value =>', ->

    it 'should hold values as a chained instance', ->
      v = [1,2,3]
      c = new Base()
      z = c.save("nodes", v).map((a) -> a * 10).commit()

      expect(c.data.nodes).to.have.length(v.length)
      expect(c.data.nodes).to.eql((n*10 for n in [1..3]))

      expect(z.value()).to.have.length(v.length)
      expect(z.value()).to.eql((n*10 for n in [1..3]))

    it 'should hold values as a chained instance', ->
      c = new Base().save("nodes", [1,2,3])
      expect(c).to.be.instanceOf(Chained)


  describe 'chained save =>', ->

    name = '_ids'

    beforeEach -> rm(join name)
    afterEach  -> rm(join name)

    it 'should provide a chained array instance from save()', ->
      db = new Base({name: name})

      ar = db.save("nodes", ({ id: n } for n in [1..100]))
        .map((k) -> { id: k.id * 100 })
        .value()

      db.save('nodes', ar)
      db.write()

  describe 'toAbsolute =>', ->

    it 'should add .json', ->
      name = Base.toAbsolute('my-db')
      expect(path.basename name).to.equal('my-db.json')

  describe 'save + write =>', ->
    db = null
    name = 'saved-1.json'
    vals = [5,1,3]

    beforeEach ->
      db = new Base(name : name)
      db.save('other')
      db.save("stuff", vals)
      db.write()

    afterEach ->
      rm(join name)

    it 'should read saved data and compare gaurantee data', ->
      expect(exists db.file).to.be.true

      d = new Base(file : db.file)

      expect(d.data.other).to.exist
      expect(d.data.other).to.have.length(0)
      expect(d.data.other).to.to.instanceOf(Array)

      expect(d.data.stuff).to.exist
      expect(d.data.stuff).to.have.length(vals.length)
      expect(d.data.stuff).to.to.instanceOf(Array)
      expect(d.data.stuff).to.eql(vals)

  describe 'save =>', ->

    it 'should save data to collection and to underlying db', ->
      vals = [5,1,3]
      db = new Base()
      db.save('other')
      db.save("stuff", vals)

      expect(db.data.other).to.exist
      expect(db.data.other).to.have.length(0)
      expect(db.data.other).to.to.instanceOf(Array)

      expect(db.data.stuff).to.exist
      expect(db.data.stuff).to.have.length(vals.length)
      expect(db.data.stuff).to.to.instanceOf(Array)


  describe 'collection =>', ->

    it 'should create a collection array for newly allocated (and defaulted) collection', ->
      db = new Base()
      db.save('stuff')
      expect(db.data.stuff).to.exist
      expect(db.data.stuff).to.have.length(0)
      expect(db.data.stuff).to.to.instanceOf(Array)

    it 'should save newly allocated collection in db', ->
      vals = [1,2,3]
      db = new Base()
      db.save('stuff', vals)
      expect(db.data.stuff).to.exist
      expect(db.data.stuff).to.have.length(vals.length)
      expect(db.data.stuff).to.to.instanceOf(Array)


  describe 'toAbsolute =>', ->

    it.skip 'should produce fully-qualified name of default db.json', ->
      console.log(Base.toAbsolute('db.json'))

  describe 'load =>', ->

    it "should read json object from file during construction if 'file' provided", ->
      db = new Base(file: 'files/s1/db-3.json')
      expect(db.data).to.deep.equal({id:1})

    it "should read json object from file", ->
      db = new Base(file: 'files/s1/db-2.json')
      data = db.load()
      expect(data).to.deep.equal({id:1})

    it "should throw an error when 'file' not provided", ->
      db = Base()
      expect(-> db.load()).to.throw(Error)

  describe 'save =>', ->

    name1 = 'db-3.json'
    name2 = 'other-db-1.json'

    afterEach ->
      rm(join name1)
      rm(join name2)
      rm(join Base._defaults.name)

    it 'should serialize the db to alt file', ->
      db = new Base(name: name1)
      db.write(join name2)
      expect(exists(db.file), "original file #{db.file}").to.be.false
      expect(exists(join name2)).to.be.true

    it 'should serialize the db file', ->
      db = new Base(name: name1)
      db.write()
      expect(exists(db.file), name1).to.be.true

    it 'should serialize the default db', ->
      db = new Base()
      db.write()
      expect(exists(db.file)).to.be.true

  describe 'construction =>', ->

    afterEach ->
      rm(join Base._defaults.name)

    it "should not allow both file and json since file implies json store", ->
      json = JSON.stringify({name:'gramatic'})
      expect(-> new Base(json : json, file : 'files/db.json')).to.throw(Error)

    it "should parse json to data object even if no json is provided", ->
      json = JSON.stringify(opts = {name:'gramatic'})
      db = new Base(json : json)
      expect(db.data).to.deep.equal(opts)

    it "should parse json to data object even if no json is provided", ->
      db = new Base()
      expect(db.data).to.deep.equal({})

    it "should accept values for 'json' default", ->
      opts = json: '{"name": "bass nectur"}'
      db = new Base(opts)
      expect(db.defaults.json).to.equal(opts.json)

    it "should accept values for 'file' default", ->
      opts = file: 'files/db.json'
      db = new Base(opts)
      expect(db.defaults.file).to.equal(opts.file)

    it "should default both 'file' and 'json'", ->
      db = new Base()

      expect(db.defaults, 'defaults').to.exist
      expect(db.defaults.file).to.be.null
      expect(db.defaults.json).to.equal('{}')

    it 'should execute w/o error', ->
      expect(-> new Base()).to.not.throw(Error)

    it 'should be a function', ->
      expect(Base).to.be.instanceOf(Function)

