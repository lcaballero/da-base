DaBase = require("../src/DaBase")

describe 'DaBase =>', ->

  describe 'contructor =>', ->

    it 'should instantiate without error', ->
      expect(-> new DaBase()).to.not.throw(Error)