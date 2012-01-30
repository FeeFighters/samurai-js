# Samurai Payment Error Handler Module
# ------------------------
$ = Samurai.jQuery

# Module for handling errors returned by the Samurai Payment module
@module "Samurai", ->
  log = Samurai.log

  class @PaymentErrorHandler
    @DEFAULT_RESPONSE_MAPPINGS = {
      default                                   : 'An unknown error occurred. Please contact support.',

      # Transaction Responses
      'info processor.transaction success'      : 'The transaction was successful.',
      'error processor.transaction declined'    : 'The card was declined.',
      'error processor.issuer call'             : 'Call the card issuer for further instructions.',
      'error processor.issuer unavailable'      : 'The authorization did not respond within the alloted time.',
      'error input.card_number invalid'         : 'The card number was invalid.',
      'error input.expiry_month invalid'        : 'The expiration date month was invalid, or prior to today.',
      'error input.expiry_year invalid'         : 'The expiration date year was invalid, or prior to today.',
      'error processor.pin invalid'             : 'The PIN number is incorrect.',
      'error input.amount invalid'              : 'The transaction amount was invalid.',
      'error processor.transaction declined_insufficient_funds' : 'The transaction was declined due to insufficient funds.',
      'error processor.network_gateway merchant_invalid'        : 'The Merchant Number is incorrect.',
      'error input.merchant_login invalid'      : 'The merchant ID is not valid or active.',
      'error input.store_number invalid'        : 'Invalid Store Number.',
      'error processor.bank_info invalid'       : 'Invalid banking information.',
      'error processor.transaction not_allowed' : 'This transaction type is not allowed.',
      'error processor.transaction type_invalid'    : 'Requested transaction type is not allowed for this card/merchant.',
      'error processor.transaction method_invalid'  : 'The requested transaction could not be performed for this merchant.',
      'error input.amount exceeds_limit'            : 'The maximum transaction amount was exceeded.',
      'error input.cvv invalid'                     : 'The CVV code was not correct.',
      'error processor.network_gateway communication_error'     : 'There was a fatal communication error.',
      'error processor.network_gateway unresponsive'            : 'The processing network is temporarily unavailable.',
      'error processor.network_gateway merchant_invalid'        : 'The merchant number is not on file.',
      'error processor.transaction duplicate'        : 'Duplicate transaction detected. This transaction was not processed.',

      # CVV Responses
      'error input.cvv declined' : 'The CVV code was not correct.',

      # Input validations
      'error input.card_number is_blank'        : 'The card number was blank.',
      'error input.card_number not_numeric'     : 'The card number was invalid.',
      'error input.card_number too_short'       : 'The card number was too short.',
      'error input.card_number too_long'        : 'The card number was too long.',
      'error input.card_number failed_checksum' : 'The card number was invalid.',
      'error input.card_number is_invalid'      : 'The card number was invalid.',
      'error input.card_number invalid'      : 'The card number was invalid.',
      'error input.cvv is_blank'                : 'The CVV was blank.',
      'error input.cvv not_numeric'             : 'The CVV was invalid.',
      'error input.cvv too_short'               : 'The CVV was too short.',
      'error input.cvv too_long'                : 'The CVV was too long.',
      'error input.cvv is_invalid'              : 'The CVV was invalid.',
      'error input.cvv invalid'                 : 'The CVV was invalid.',
      'error input.expiry_month is_blank'       : 'The expiration month was blank.',
      'error input.expiry_month not_numeric'    : 'The expiration month was invalid.',
      'error input.expiry_month is_invalid'     : 'The expiration month was invalid.',
      'error input.expiry_month invalid'        : 'The expiration month was invalid.',
      'error input.expiry_year is_blank'        : 'The expiration year was blank.',
      'error input.expiry_year not_numeric'     : 'The expiration year was invalid.',
      'error input.expiry_year is_invalid'      : 'The expiration year was invalid.',
      'error input.expiry_year invalid'         : 'The expiration year was invalid.',
    }

    # Keeps a list of all instantiated error handlers.
    @errorHandlers: []

    # Used to return a reference to the error handler of a form or
    # instantiate one if one doesn't exist, yet.
    # Make sure that the `element` argument is an actual DOM element
    # and not a jQuery collection.
    @forForm: (element) ->
      if element instanceof Samurai.jQuery
        element = element.get(0)

      for [el, handler] in PaymentErrorHandler.errorHandlers
        return handler if el is element

      return new PaymentErrorHandler $(element)

    # Deprecated because of reserved word use. Will be removed in v0.2
    @for: @forForm

    # Setup the error handler for `@form` and respond to the payment event
    constructor: (@form) ->
      @form = $(@form)
      @form
        .bind('payment', @handlePaymentEvent)
        .submit(@reset)
      @currentErrorMessages = []
      PaymentErrorHandler.errorHandlers.push [@form.get(0), this]
      log 'Error handler attached to ', @form

    # This method simply passes the response on to the `handleErrorsFromResponse` method
    # in its default implementation, but you can always replace it with your own if you
    # need it to do more than that.
    handlePaymentEvent: (event, response) =>
      @handleErrorsFromResponse(response)

    # Loops through the messages block and calls the `parseErrorMessage` method
    # for each message with a class of `error`. At the end of the method, a
    # `errors` event is triggered, which we hook into to provide users a
    # summary of all errors.
    #
    # This method will usually get called by handlePaymentEvent when a `payment` event
    # is triggered, but you can easily use it on its own like this:
    #
    # `Samurai.PaymentErrorHandler.forForm($('#myform').get(0)).handleErrorsFromResponse(jsonResponse)`
    #
    # Note that this method doesn't handle the display of errors.
    # When it finds an error, it triggers the `error` event and passes on the
    # error message. This allows you to intercept the `error` event and handle
    # the display of errors yourself.  If not, the built-in
    # `highlightFieldWithError` method of PaymentErrorRenderer will respond to
    # this event and highlight the erroneous field in the default style.
    handleErrorsFromResponse: (response) ->
      messages = @extractErrorMessagesFromResponse(response)
      return unless messages.length

      # Sort the messages so that we handle the higher-priority messages first
      messages = messages.sort (a,b) ->
        test = (v) -> $.inArray v, ['is_blank', 'not_numeric', 'too_short', 'too_long', 'failed_checksum']
        test(a.key || '') - test(b.key || '')

      # Make sure the errors are unique'd, by message.context
      messages = $.grep messages, (v, k) -> $.inArray(v.context, $.map messages, (m) -> m.context) == k

      for message in messages
        @form.trigger 'error', [message]
        @currentErrorMessages.push(message)

      @form.trigger 'errors', [@currentErrorMessages] if @currentErrorMessages.length > 0

    # Performs a deep traversal of the response object, and looks for
    # message arrays along the way. This method is needed because sometimes
    # you can have both the payment_method and processor responses in the same
    # JSON object, each with their own respective messages array. This method
    # saves you from having to remember the paths to these message arrays and
    # lumps all messages together.
    extractErrorMessagesFromResponse: (response) ->
      messages = []
      extr = (hash) ->
        for own key, value of hash
          if key is 'messages'
            messages = messages.concat(value)
          else
            extr(value) if typeof value is 'object'

      extr(response)
      # sometimes a message is returned as a shallow object in an array of messages,
      # sometimes it's inside an additional `message` object wrapper. This expression
      # makes sure the two are the same.
      messages = $.map messages, (m) -> if m.message then m.message else m
      messages = (@parseErrorMessage(m) for m in messages when m.class is 'error' or m.subclass is 'error')
      return messages

    # Decorates the error message with the humanized error text that corresponds to the message key
    parseErrorMessage: (message) ->
      mappings = PaymentErrorHandler.DEFAULT_RESPONSE_MAPPINGS
      message.text = mappings["error #{message.context} #{message.key}"] || mappings.default
      return message
      
    # Wipes the internal error message array.
    reset: =>
      @currentErrorMessages = []
