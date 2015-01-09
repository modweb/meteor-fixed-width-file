# fixed-width-file.litcoffee

This file has the methods to prepare a fixed width file and then write it to the
file system.

## Meteor methods

To use, call Meteor.call 'prepareFixedWidth' with the following parameters
* data: The data to be written to the file. Should be a javascript array of
objects. Values do not have to be a string. E.g.:
```coffeescript
data = [
  {
    name: 'Person 1'
    number: '555-555-5555'
    address: '123 Alphabet Rd'
  }
  {
    name: 'Person 2'
    number: '555-555-5550'
    address: '1234 Alphabet Rd'
  }
]
```
* schema: The schema to follow when creating the file output. E.g.:
```coffeescript
schema = [
  {
    # The name of the key value to be written
    key: 'name'
    # How wide the column should be for the value
    width: 20
  }
  {
    key: 'number'
    width: 15
  }
]
```
* fileName: The name of the file to be written as a string. E.g.: `'file.txt'`
* path: The path to the location to save the file as a string. Has checks to
prevent writing to certain locations as well as stripping extra slashes. E.g.:
`'files/fixed/width'`

__PLEASE NOTE. A PUBLIC DIRECTORY MUST EXIST IN YOUR METEOR DIRECTORY!__
Beginning FixedWidth:

    FixedWidth.prepareFixedWidth = (data, schema, fileName, path = null) ->

Create the initial black result string (where we will keep track of what will
be written later). Iterate over each object in the data array, and use the
schema to prepare a single line, which we then add to the result

      result = ''
      for object in data
        result += Helper.prepareSingleLine object, schema

With the newly created result, save the file to the given path with the given
filename. Use utf8 encoding. Then return the resulting string.

      if result.length > 0
        Helper.saveFile result, fileName, path, 'utf8'
      result

## Helper Functions

This function is responsible for preparing one line of the fixed width file. It
also logs the object, schema, value before toString is called, and the width the
schema calls for each iteration for debugging purposes (for now).

    Helper.prepareSingleLine = (object, schema) ->
      result = ''
      for entry in schema
        value = object[entry.key]
        width = entry.width
        if not entry.key? or not width?
          throw new Meteor.error 500, 'Malformed schema. Missing key or width.'

Check if the value exists. If it does, call toString() for any values that could
be integers, etc. We log that and see if the value is either longer or shorter
than what the schema calls for. If it is shorter than what's called for, we add
whitespace to the end of it. If it's longer than the desired value, we trim it
down to size.

        if value?
          value = value.toString()
          valueLengthIsTooLong = value.length > width
          valueLengthIsTooShort = value.length < width
          if valueLengthIsTooLong
            value = value.substr(0, width)
          else if valueLengthIsTooShort
            value = value + new Array(width - value.length + 1).join(' ')

If the value doesn't exist, we write whitespace to the desired width and log it.

        else
          value = new Array(width + 1).join(' ')

Regardless, we add that value to the result.

        result += value

We check to make sure at least one value was written. If there was, we add a
trailing new line.

      isValidSingleLine = !!result.match /\S/
      if isValidSingleLine then result += '\n' else ''

Method to save the file. Writes the blob of data to the supplied path with the
provided filename and encoding.

    Helper.saveFile = (blob, fileName, path, encoding) ->

Clean up the path. We remove the initial and final '/' since we add them
ourselves. We also block any attempt to go to the parent directory. We then
remove consecutive '////' that could occur after removing '..'. We then require
the filesystem node module (fs), clean the filename, and assume utf8 encoding if
none was provided.

      path = Helper.cleanPath path
      fs = Npm.require 'fs'
      fileName = Helper.cleanName fileName or 'file'
      encoding = encoding or 'utf8'

      chroot = process.env['PWD'] + '/public'

Construct the path.

      path = chroot + (if path? then "/#{path}/" else '/')

Write the file and throw any errors if there are issues. Write to the console if
things go well.

      fs.writeFileSync path + fileName, blob, encoding, (error) ->
        if error?
          throw new Meteor.Error 500, 'Failed to save file. ' + error.message
        else
          console.log "The file #{fileName} (#{encoding}) was saved to #{path}"

The cleanPath function removes all '..' and extraneous '/'

    Helper.cleanPath = (str) ->
      str.replace(/\.\./g, '').replace(/\/+/g, '').replace(/^\/+/,
        '').replace /\/+$/, ''  if str

The cleanName method does the same thing.

    Helper.cleanName = (str) -> str.replace(/\.\./g, '').replace /\//g, ''
