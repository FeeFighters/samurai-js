# Samurai Payment Error Handler Module
# ------------------------
$ = jQuery

# Module for performing ajax payment transactions
@module "Samurai", ->
  ERROR_MESSAGES = {
    not_numeric: 'must be a number.'
    too_short: 'is too short.'
  }
  log = Samurai.log

  class @PaymentErrorHandler
    @errorHandlers: [] 

    @for: (element) ->
      for {el, handler} in PaymentErrorHandler.errorHandlers
        return handler if el is element

      return new PaymentErrorHandler $(element)

    constructor: (@form, @config={}) ->
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

    handlePaymentEvent: (event, response) =>
      @handleErrorsFromResponse(response)

    handleErrorsFromResponse: (response) ->
      messages = response.payment_method?.messages || []
      for message in messages
        if message.class is 'error'
          @parseErrorMessage(message) 
          @currentErrorMessages.push(message)

      if @currentErrorMessages.length > 0
        @form.trigger 'samurai.errors-shown', [@currentErrorMessages]

    parseErrorMessage: (message) ->
      [context, field] = message.context.split('.')
      input = @form.find '[name="credit_card['+field+']"]'
      text = ERROR_MESSAGES[message.key]
      @form.trigger 'samurai.show-error', [input, text, message]

    showError: (event, input, text, message) =>
      input.addClass @config.inputErrorClass
      label = input.siblings('label')
      if label.length is 0 then label = input.closest('label')
      label.addClass @config.labelErrorClass
      input.after('<span class="'+@config.descriptionClass+'">'+text+'</span>')
      @form.trigger 'samurai.error-shown', [input, text]

    reset: =>
      @form.find('.'+@config.inputErrorClass).removeClass(@config.inputErrorClass)
      @form.find('.'+@config.labelErrorClass).removeClass(@config.labelErrorClass)
      @form.find('.'+@config.descriptionClass).remove()
      @currentErrorMessages = []
