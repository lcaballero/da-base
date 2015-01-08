Chained = require '../../src/chained'

describe 'chained-tests =>', ->

  describe 'construct chain with array =>', ->

    it 'should propagate name of collection', ->
      vals = [1,2,3]
      a1 = new Chained({ data: vals, name: 'the flash', db: {id:42} })
      b1 = a1.map((a) -> a * 10).first()

      expect(b1.name).to.equal('the flash')
      expect(b1.db).to.exist
      expect(b1.db.id).to.equal(42)

    it 'should reduce to a single value', ->
      vals = [1,2,3]
      a1 = new Chained({ data: vals })
      b1 = a1.map((a) -> a * 10).first()
      v = b1.value()
      expect(v).to.equal(vals[0] * 10)

    it 'should propagate the newly transformed value', ->
      vals = [1,2,3]
      a1 = new Chained({ data: vals })
      b1 = a1.map((a) -> a * 10)

      v = b1.value()
      expect(v).to.have.length(v.length)

    it 'each chain call should produce a Chained instance', ->
      a1 = new Chained({ data: [1,2,3] })
      b1 = a1.map((a) -> a * 10)

      expect(a1).to.be.instanceOf(Chained)
      expect(b1).to.be.instanceOf(Chained)

