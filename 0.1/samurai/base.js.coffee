# Samurai Base
# ------------------------

# helper so we can use modules to break functionality into separate files
# See:  https://github.com/jashkenas/coffee-script/wiki/Easy-modules-with-CoffeeScript
@module = (names, fn) ->
  names = names.split '.' if typeof names is 'string'
  space = @[names.shift()] ||= {}
  space.module ||= @module
  if names.length
    space.module names, fn
  else
    fn.call space
