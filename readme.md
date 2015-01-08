[![Build Status](https://travis-ci.org/lcaballero/da-base.svg?branch=master)](https://travis-ci.org/) [![NPM version](https://badge.fury.io/js/da-base.svg)](http://badge.fury.io/js/da-base)

# Introduction

`da-base` is an in-memory data store.  It provides access to via the underlying data
a [lodash][lodash] like interface.  The code is based on two classes `DaBase` and
`Chained`.  The first holds the complete data of the database and the second provides
access to single collections.  Collections are typically intended to be arrays of
data, but that's not an explicit limitation.

## Usage

```
db = new DaBase({ name: 'four' })
db.save('nodes', [1,2,3,4])
  .map(function(a) { return a * 10 })
  .commit()
  .write();
```

The above code creates an in memory representation of the following JSON:

```
{
  "nodes": [ 10, 20, 30, 40 ]
}
```

This usage is a combination of both `DaBase` and `Chained`.  `DaBase#save` returns
a new collection with the given name and the (optional) value that is encapsulated
by a `Chained` instance.  The `Chained` instance provides `map()`, `commit()`, and
`write()`.  However, `map()` is carried out by the [lodash][lodash] library, while
`commit()` and `write()` alter the original database.  `commit()` updates the
database with the value transformed by the `Chained` instance, and `write()` flushes
the data to a JSON file.

# API

## DaBase

##### ctor(opts)

```
{
  dir: '...'      (optional) [default: ./files]
  file: '...'     (optional) [default: null]
  name: '...'     (optional) [default: db.json]
  json: '...'     (optional) [default: '{}']
  parse: function (optional) [default: JSON.parse]
}
```

From these options a location for a file must be derivable.  So, either a full
filename is given or one can be derived from the options as such:
"{dir}/{name}.db".  Or, possibly just the JSON might be provided which can be
parsed using the parse function.

##### write(file)

Writes the underlying data as JSON to the Database file.  The file name is derived
as from the DB file and name options "dir/name.json" which would defaults to
"file/db.json".

##### save(name, [val])

Save creates a collection in the Database with the given value if it is provided.
If `val` is not provided it will be defaulted to an empty Array.  Nothing limits
the value to an array or object, but any value, however it results in a Chained
instance that wraps the given value, and operations must take that value's type
into consideration (see [lodash][lodash]).

##### load([file])

Loads the JSON found in the given file.  If the filename is not provided it
derives the file name from options given to the database on instantiation.

## Chained

##### ctor(opts)

```
{
  data: [default: empty-array]
  name: [default: 'unknown']
  db:   [default: 'unknown']
}
```

##### commit(array)

Saves the given array to the database using the collection name when it was
accessed using the `DaBase.save(name,[val])` method.  If the array is not
given then the underlying data (as transformed by it's lodash interface) will
be saved to the collection name.

##### write(file)

Writes the Database to file WITHOUT using the current data of the Chained
instance.  Typically, `commit()` is called prior `write()` to first push
the data into the database and the serialize that data to file.

##### chainable lodash functions

[Chainable lodash functions][lodash-chain].


## License

See license file.

The use and distribution terms for this software are covered by the
[Eclipse Public License 1.0][EPL-1], which can be found in the file 'license' at the
root of this distribution. By using this software in any fashion, you are
agreeing to be bound by the terms of this license. You must not remove this
notice, or any other, from this software.


[EPL-1]: http://opensource.org/licenses/eclipse-1.0.txt
[lodash]: https://lodash.com/docs
[lodash-chain]: https://lodash.com/docs#_

