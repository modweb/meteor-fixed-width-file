# Server side tests
if Meteor.isServer
  Tinytest.add 'prepareSingleLine - normal case', (test) ->
    object =
      name: 'Dustin'
      phone: '555-555-5555'
    schema = [
      key: 'name'
      length: 10
    ,
      key: 'phone'
      length: 15
    ]
    result = prepareSingleLine object, schema
    expectedResult = 'Dustin    555-555-5555   \n'
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
