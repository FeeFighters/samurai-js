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
      summary_header: 'We found some errors in the information you were trying to submit:'
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
        descriptionClass: 'error-description',
        errorSummaryClass: 'error-summary'
        @config)

      @form = $(@form)
      @form
        .bind('samurai.payment', @handlePaymentEvent)
        .submit(@reset)
        .bind('samurai.show-error', @highlightFieldWithErrors)
        .bind('samurai.errors-shown', @showErrorSummary)
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
    # a `samurai.errors-shown` event is triggered, which we hook into to
    # provide users a summary of all errors.
    #
    # This method will usually get called by handlePaymentEvent when a samurai.payment event
    # is triggered, but you can easily use it on its own like this:
    #
    # `Samurai.PaymentErrorHandler.for($('#myform')).handleErrorsFromResponse(jsonResponse)`
    #
    # Note that this method doesn't handle the display of errors.
    # When it finds an error, it triggers the `samurai.show-error` event and passes on
    # the affected input field and the humanized error message. This allows you to
    # intercept the `show-error` event and handle the display of errors yourself.
    # If not, the built-in `highlightFieldWithError` method will respond to this event 
    # and highlight the erroneous field in the default style.
    handleErrorsFromResponse: (response) ->
      messages = response.payment_method?.messages || response.messages || [] 
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
    # input field and its nearest label.
    # It also triggers an `error-shown` event after these changes with the affected input element
    # and the error message as arguments.
    highlightFieldWithErrors: (event, input, text, message) =>
      input.addClass @config.inputErrorClass
      label = input.siblings('label')
      if label.length is 0 then label = input.closest('label')
      label.addClass @config.labelErrorClass
      @form.trigger 'samurai.error-shown', [input, text]

    showErrorSummary: (event, messages) =>
      errors = []
      for message in messages
        [input, text] = @parseErrorMessage(message)
        # try to find the nearest label to get the name of the field that contains
        # the error. If no label is around, default to the name inside the context
        # key of the returned message.
        label = input.siblings('label')
        if label.length is 0 then label = input.closest('label')
        if label.length is 0
          fieldName = message.context.split('.')[1].replace(/_/, ' ')
        else
          fieldName = $.trim(label.text()).replace(/:$/, '') # strip trailing colon from labels that have it

        errors.push "<li><em class=\"field-with-error-name\">#{fieldName}</em> #{text}</li>"

      errorContainerHTML = """
      <div class="#{@config.errorSummaryClass}">
        <strong>#{PaymentErrorHandler.ERROR_MESSAGES.summary_header}</strong>
        <ul>
          #{errors.join('')}
        </ul>
      </div>
      """

      @form
        .find('.'+@config.errorSummaryClass).remove().end()
        .find('[type="submit"]').last()
          .before(errorContainerHTML)

    # Clears all errors and wipe the internal error message array.
    reset: =>
      @form
        .find('.'+@config.inputErrorClass).removeClass(@config.inputErrorClass).end()
        .find('.'+@config.labelErrorClass).removeClass(@config.labelErrorClass).end()
        .find('.'+@config.descriptionClass).remove().end()
        .find('.'+@config.errorSummaryClass).remove()
      @currentErrorMessages = []
