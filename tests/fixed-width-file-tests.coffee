# Server side tests
if Meteor.isServer
  normalObject =
    name: 'Dustin'
    phone: '555-555-5555'

  objectWithNumber =
    name: 'Dustin'
    phone: 5555555555

  objectWithMissingField =
    name: 'Dustin'

  objectWithExtraField =
    name: 'Dustin'
    phone: 5555555555
    extraStuff: 'I should be ignored'

  objectWithUselessFields =
    stuff: 'This is useless'
    other: 123456789
    extra: 'Really, this should be'

  normalObjectArray = [
    {
      name: 'Dustin'
      phone: '555-555-5555'
    }
    {
      name: 'Other'
      phone: '555-555-5555'
    }
  ]

  schema = [
    key: 'name'
    width: 10
  ,
    key: 'phone'
    width: 15
  ]

  badSchema = [
    key: 'name'
    notWidth: 'schema needs a width, yo'
  ]

  ### Cases:
    ✔ the normal case: all fields are present in the schema
    ✔ number case: make sure numbers are treated properly
    ✔ missing a field: expect to fill that fields with white-space
    ✔ extra field not in schema: extra field ignored
    ✔ all fields not in schema: returns an empty string
    ✔ bad file name: makes the file name 'file'
    ✔ writing file: make sure correct data is written
    ✔ malformed data: no data written
    ✔ malformed schema: error
    ✔ malformed path: Path should be fixed automatically
  ###

  Tinytest.add 'prepareSingleLine - normal case', (test) ->
    result = Helper.prepareSingleLine normalObject, schema
    expectedResult = 'Dustin    555-555-5555   \n'
    test.equal result, expectedResult

  Tinytest.add 'prepareSingleLine - number case', (test) ->
    result = Helper.prepareSingleLine objectWithNumber, schema
    expectedResult = 'Dustin    5555555555     \n'
    test.equal result, expectedResult

  Tinytest.add 'prepareSingleLine - missing field case', (test) ->
    result = Helper.prepareSingleLine objectWithMissingField, schema
    expectedResult = 'Dustin                   \n'
    test.equal result, expectedResult

  Tinytest.add 'prepareSingleLine - extra field not in schema case', (test) ->
    result = Helper.prepareSingleLine objectWithExtraField, schema
    expectedResult = 'Dustin    5555555555     \n'
    test.equal result, expectedResult

  Tinytest.add 'prepareSingleLine - all fields not in schema', (test) ->
    result = Helper.prepareSingleLine objectWithUselessFields, schema
    expectedResult = ''
    test.equal result, expectedResult

  Tinytest.add 'write file - missing or bad filenames should be named file', (test) ->
    chroot = Meteor.chroot or process.env['PWD']
    FixedWidth.prepareFixedWidth normalObjectArray, schema, '', 'testDirectory'
    fs = Npm.require 'fs'
    path = chroot + '/testDirectory/file'
    fd = fs.openSync path, 'r'
    test.equal fd?, true
    if fd? then fs.closeSync fd

  Tinytest.add 'write file - make sure data is correct from file', (test) ->
    chroot = Meteor.chroot or process.env['PWD']
    FixedWidth.prepareFixedWidth normalObjectArray, schema, 'hello.txt',
      'testDirectory'
    fs = Npm.require 'fs'
    path = chroot + '/testDirectory/hello.txt'
    content = fs.readFileSync(path).toString()
    expected = 'Dustin    555-555-5555   \nOther     555-555-5555   \n'
    test.equal content, expected

  Tinytest.add 'write file - make sure nothing is written with bad data',
  (test) ->
    chroot = Meteor.chroot or process.env['PWD']
    try
      FixedWidth.prepareFixedWidth normalObjectArray, schema, 'hello.txt',
        'testDirectory'
    catch error
      test.isNotNull error
    fs = Npm.require 'fs'
    path = chroot + '/testDirectory/badData.txt'
    fd = null
    try
      fd = fs.openSync path, 'r'
    catch err
      # if we're here, it's probably because the file doesn't exist
      # this is a good thing
    finally
      test.equal fd?, false
      if fd? then fs.closeSync fd

  Tinytest.add 'write file - make sure an error is thrown if the schema is bad',
    (test) ->
      try
        FixedWidth.prepareFixedWidth normalObjectArray, badSchema, 'nofile.txt',
          'testDirectory'
      catch err
        test.equal err?, true


  Tinytest.add 'write file - fix malformed paths', (test) ->
    chroot = Meteor.chroot or process.env['PWD']
    FixedWidth.prepareFixedWidth normalObjectArray, schema, 'pathTest.txt',
      '../testDirectory/',
    fs = Npm.require 'fs'
    path = chroot + '/testDirectory/pathTest.txt'
    fd = fs.openSync path, 'r'
    test.equal fd?, true
    if fd? then fs.closeSync fd
