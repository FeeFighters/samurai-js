# Samurai Payment Legacy Events Module
# ------------------------
$ = Samurai.jQuery

# Module for hooking up legacy samurai.* event handling, to ensure backward-compatibility
@module "Samurai", ->
  @PaymentsLegacyEvents = do ->

    init = ->
      attachHandlers() unless Samurai.config.withoutLegacyEvents # attach legacy event handlers to any payment forms

    attachHandlers = ->
      samurai = this
      $('form').each ->

        $(this).bind 'loading', (event) ->
          Samurai.log 'Triggering legacy event: samurai.loading'
          $(this).trigger 'samurai.loading'

        $(this).bind 'payment', (event, data) ->
          Samurai.log 'Triggering legacy event: samurai.payment'
          $(this).trigger 'samurai.payment', data

        $(this).bind 'errors-shown', (event, input, text) ->
          Samurai.log 'Triggering legacy event: samurai.errors-shown'
          $(this).trigger 'samurai.errors-shown', [input, text]

        $(this).bind 'show-error', (event, input, text, message) ->
          Samurai.log 'Triggering legacy event: samurai.show-error'
          $(this).trigger 'samurai.show-error', [input, text, message]

        # This one is user-triggered, so it is flipped
        $(this).bind 'samurai.completed', (event) ->
          Samurai.log 'Responding to legacy event: samurai.completed'
          $(this).trigger 'completed'

    # Export public API
    {init}


