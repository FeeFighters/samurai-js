# Samurai Events Module
# ------------------------

$ = Samurai.jQuery

# A thin wrapper around our isolated copy of jQuery's event system.
@module "Samurai", ->
  # Bind an event handler `callback` to the collection of elements
  # identified by `selector` for the event `event`
  @on = (selector, event, callback) ->
    $(selector).on(event, callback)

  # Unbind an event handler `callback` from the collection of elements
  # identified by `selector` for the event `event`.
  # `callback` is optional and when omitted, all event handlers for the
  # specified event will be unbound.
  @off = (selector, event, callback) ->
    $(selector).on(event, callback)

  # Trigger an `event` on a DOM element identified by `selector`
  # with optional `data`
  @trigger = (selector, event, data) ->
    $(selector).trigger(event, data)