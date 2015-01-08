global._      = require('lodash')
global.chai   = require 'chai'
global.expect = chai.expect

console.json = (args...) ->
  console.log.apply(console, _.map(args, (a) -> JSON.stringify(a, null, '  ')))