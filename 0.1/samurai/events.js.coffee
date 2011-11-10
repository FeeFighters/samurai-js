# Samurai Events Module
# ------------------------

$ = Samurai.jQuery

# A thin wrapper around our isolated copy of jQuery's event system.
@module "Samurai", ->
  @on = (selector, event, callback) ->
    $(selector).on(event, callback)
