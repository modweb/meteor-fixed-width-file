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
  schema = [
    key: 'name'
    width: 10
  ,
    key: 'phone'
    width: 15
  ]

  Tinytest.add 'prepareSingleLine - normal case', (test) ->
    result = prepareSingleLine normalObject, schema
    expectedResult = 'Dustin    555-555-5555   \n'
    test.equal result, expectedResult

  Tinytest.add 'prepareSingleLine - number case', (test) ->
    result = prepareSingleLine objectWithNumber, schema
    expectedResult = 'Dustin    5555555555     \n'
    test.equal result, expectedResult

  Tinytest.add 'prepareSingleLine - missing field case', (test) ->
    result = prepareSingleLine objectWithMissingField, schema
    expectedResult = 'Dustin                   \n'
    test.equal result, expectedResult

### Cases:
  the normal case: all fields are present in the schema
  missing a field: expect to fill that fields with white-space
  extra field not in schema: ?
  all fields not in schema: do nothing?
  bad file name: error
  malformed data: error
  malformed schema: error
  malformed filename: error
  malformed path: error

###
