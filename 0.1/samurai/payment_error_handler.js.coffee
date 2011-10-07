# Samurai Payment Error Handler Module
# ------------------------
$ = jQuery

# Module for handling errors returned by the Samurai Payment module
@module "Samurai", ->
  log = Samurai.log

  class @PaymentErrorHandler
    # Since error messages are returned in key form only,
    # we need to convert them to a human-readable form before we show
    # them to the user. This hash contains the default translations
    # for these keys. Feel free to overwrite it with your own.
    @ERROR_MESSAGES = {
      not_numeric: 'must be a number.'
      too_short: 'is too short.'
    }

    # Keeps a list of all instantiated error handlers.
    @errorHandlers: [] 

    # Used to return a reference to the error handler of a form or
    # instantiate one if one doesn't exist, yet.
    # Make sure that the `element` argument is an actual DOM element
    # and not a jQuery collection.
    @for: (element) ->
      for {el, handler} in PaymentErrorHandler.errorHandlers
        return handler if el is element

      return new PaymentErrorHandler $(element)

    # Setup the error handler for `@form` and respond to the payment,
    # submit and show-error events.
    constructor: (@form, @config={}) ->
      # You can pass your own config values to the constructor
      # if you're planning to let Samurai handle the display of errors,
      # but would just like to use different class names.
      @config = $.extend(
        inputErrorClass: 'error',
        labelErrorClass: 'error',
        descriptionClass: 'error-description'
        @config)

      @form = $(@form)
      @form.bind('samurai.payment', @handlePaymentEvent)
        .submit(@reset)
        .bind('samurai.show-error', @showError)
      @currentErrorMessages = []
      PaymentErrorHandler.errorHandlers.push @form.eq(0), this
      log 'Error handler attached to ', @form

    # This method simply passes the response on to the `handleErrorsFromResponse` method
    # in its default implementation, but you can always replace it with your own if you
    # need it to do more than that.
    handlePaymentEvent: (event, response) =>
      @handleErrorsFromResponse(response)

    # Loops through the messages block and calls the `parseErrorMessage` method
    # for each message with a class of `error`. At the end of the method,
    # a `samurai.errors-shown` event is triggered, which you could hook into to
    # provide users a summary of all errors, for example.
    #
    # To method will usually get called by handlePaymentEvent when a samurai.payment event
    # is triggered, but you can easily use it independently like this:
    #
    # `Samurai.PaymentErrorHandler.for($('#myform')).handleErrorsFromResponse(jsonResponse)`
    #
    # Note that this method doesn't handle the display of errors on its own.
    # When it finds an error, it triggers the `samurai.show-error` event and passes on
    # the affected input field and the humanized error message. This allows you to
    # intercept the `show-error` event and handle the display of errors yourself.
    # If not, the built-in showError method will respond to this event and show the error
    # in the default style.
    handleErrorsFromResponse: (response) ->
      messages = response.payment_method?.messages || []
      for message in messages
        if message.class is 'error'
          [input, text] = @parseErrorMessage(message)
          @form.trigger 'samurai.show-error', [input, text, message]
          @currentErrorMessages.push(message)

      if @currentErrorMessages.length > 0
        @form.trigger 'samurai.errors-shown', [@currentErrorMessages]

    # Returns a jQuery collection that contains the element with invalid value
    # and the humanized error text that corresponds to the message key
    parseErrorMessage: (message) ->
      [context, field] = message.context.split('.')
      input = @form.find '[name="credit_card['+field+']"]'
      text = PaymentErrorHandler.ERROR_MESSAGES[message.key]
      [input, text]

    # The default error renderer for Samurai. Adds the `error` class names to the
    # input field and its nearest label, and inserts an `.error-description` span after the
    # field. It also triggers an `error-shown` event after these changes with the affected input element
    # and the error message as arguments.
    showError: (event, input, text, message) =>
      input.addClass @config.inputErrorClass
      label = input.siblings('label')
      if label.length is 0 then label = input.closest('label')
      label.addClass @config.labelErrorClass
      input.after('<span class="'+@config.descriptionClass+'">'+text+'</span>')
      @form.trigger 'samurai.error-shown', [input, text]

    # Clears all errors and wipe the internal error message array.
    reset: =>
      @form.find('.'+@config.inputErrorClass).removeClass(@config.inputErrorClass)
      @form.find('.'+@config.labelErrorClass).removeClass(@config.labelErrorClass)
      @form.find('.'+@config.descriptionClass).remove()
      @currentErrorMessages = []
