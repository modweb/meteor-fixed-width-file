# modweb:fixed-width-file

Write fixed with files based on schema and data.

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

Fixedwidth.prepareFixedWidth data, schema, 'filename.txt'
```
