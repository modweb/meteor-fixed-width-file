Meteor.methods
  prepareFixedWidth: (data, schema, fileName, path = null) ->
    # the string to write to the file
    result = ''
    for object in data
      result += prepareSingleLine object, schema

    Meteor.call('saveFile', result, fileName, path, 'utf8')
    result
  saveFile: (blob, fileName, path, encoding) ->
    # Clean up the path. Remove any initial and final '/' -we prefix them-,
    # any sort of attempt to go to the parent directory '..'
    # and any empty directories in
    # between '/////' - which may happen after removing '..'
    path = cleanPath path
    fs = Npm.require 'fs'
    fileName = cleanName fileName or 'file'
    encoding = encoding or 'utf8'

    # get the working directory of the meteor process
    chroot = Meteor.chroot or (process.env['PWD'] + '/public')

    # create the path
    path = chroot + (if path? then "/#{path}/" else '/')

    # write the blog to the file for the path and filename and encoding
    fs.writeFile path + fileName, blob, encoding, (error) ->
      if error
        throw new Meteor.Error 500, 'Failed to save file.', error
      else
        console.log "The file #{fileName} (#{encoding}) was saved to #{path}"

# Helpers
@prepareSingleLine = (object, schema) ->
  result = ''
  for entry in schema
    console.log object
    console.log entry
    value = object[entry.key]
    width = entry.width
    console.log value

    if value?
      console.log value
      valueLengthIsTooLong = value.length > width
      valueLengthIsTooShort = value.length < width
      console.log valueLengthIsTooShort
      if valueLengthIsTooLong
        console.log 'Value length is longer than desired width'
        # trim value to max allowed width
        value = value.substr(0, width)
      else if valueLengthIsTooShort
        # pad with white space
        console.log 'Value length is shorter than desired width'
        value = value + new Array(width - value.length + 1).join(' ')
    else
      # value doesn't exists, fill with whitespace
      value = new Array(width + 1).join(' ')
      console.log 'Value does not exist'

    # concat the value to the result
    result += value
  # check to make sure at least one value was written to the line
  # result contains at least one non-whitespace character
  isValidSingleLine = !!result.match /\S/
  if isValidSingleLine then result += '\n' else ''

cleanPath = (str) ->
  str.replace(/\.\./g, '').replace(/\/+/g, '').replace(/^\/+/,
    '').replace /\/+$/, ''  if str

cleanName = (str) -> str.replace(/\.\./g, '').replace /\//g, ''
