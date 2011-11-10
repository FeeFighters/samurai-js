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

        $(this).bind 'loading' (event, data) ->
          $(this).trigger 'samurai.loading', data

        $(this).bind 'payment' (event, data) ->
          $(this).trigger 'samurai.payment', data

        $(this).bind 'errors-shown' (event, data) ->
          $(this).trigger 'samurai.errors-shown', data

        $(this).bind 'show-error' (event, data) ->
          $(this).trigger 'samurai.show-error', data

        $(this).bind 'completed' (event, data) ->
          $(this).trigger 'samurai.completed', data

