Meteor.methods
  prepareFixedWidth: (data, schema, fileName, path = null) ->
    result = ''
    for object in data
      for entry in schema
        console.log object
        console.log entry
        value = object[entry.key]
        width = entry.width
        console.log value

        if value?
          console.log value
          if value.length > width
            console.log 'Value length is longer than desired width'
            value = value.substr(0, width)
          else if value.length < width
            value = value + new Array(width - value.length + 1).join(' ')
        else
          value = new Array(width + 1).join(' ')
          console.log 'Value does not exist'

        result = result + value
      result = result + '\n'

    Meteor.call('saveFile', result, fileName, path, 'utf8')
    result
  saveFile: (blob, name, path, encoding) ->
    # Clean up the path. Remove any initial and final '/' -we prefix them-,
    # any sort of attempt to go to the parent directory '..'
    # and any empty directories in
    # between '/////' - which may happen after removing '..'

    cleanPath = (str) ->
      str.replace(/\.\./g, '').replace(/\/+/g, '').replace(/^\/+/,
        '').replace /\/+$/, ''  if str

    cleanName = (str) ->
      str.replace(/\.\./g, '').replace /\//g, ''

    path = cleanPath path
    fs = Npm.require 'fs'
    name = cleanName(name or 'file')
    encoding = encoding or 'utf8'
    chroot = Meteor.chroot or (process.env['PWD'] + '/public')

    path = chroot + (if path then '/' + path + '/' else '/')
    fs.writeFile path + name, blob, encoding, (err) ->
      if err
        throw (new Meteor.Error(500, 'Failed to save file.', err))
      else
        console.log 'The file ' + name + ' (' +
          encoding + ') was saved to ' + path
      return

    return
