# Samurai Payment Error Renderer Module
# ------------------------
$ = Samurai.jQuery

# Module for rendering errors on a Samurai payment form
@module "Samurai", ->
  log = Samurai.log

  class @PaymentErrorRenderer
    @ERROR_MESSAGES = {
      summary_header: 'We found some errors in the information you were trying to submit:'
    }

    # Keeps a list of all instantiated error handlers.
    @errorRenderers: []

    # Used to return a reference to the error handler of a form or
    # instantiate one if one doesn't exist, yet.
    # Make sure that the `element` argument is an actual DOM element
    # and not a jQuery collection.
    @forForm: (element) ->
      if element instanceof Samurai.jQuery
        element = element.get(0)

      for [el, handler] in PaymentErrorRenderer.errorRenderers
        return handler if el is element

      return new PaymentErrorRenderer $(element)

    constructor: (@form, @config={}) ->
      # You can pass your own config values to the constructor
      # if you're planning to let Samurai handle the display of errors,
      # but would just like to use different class names.
      @config = $.extend(
        inputErrorClass: 'error',
        labelErrorClass: 'error',
        errorSummaryClass: 'error-summary'
        @config)

      @form = $(@form)
      @form
        .submit(@reset)
        .bind('error', @highlightFieldWithErrors)
        .bind('errors', @showErrorSummary)

      PaymentErrorRenderer.errorRenderers.push [@form.get(0), this]
      log 'Error renderer attached to ', @form

    # The default error renderer for Samurai. Adds the `error` class names to
    # the input field and its nearest label. It also triggers an `error-shown`
    # event after these changes with the affected input element and the error
    # message as arguments.
    highlightFieldWithErrors: (event, message) =>
      [context, field] = message.context.split('.')
      input = @form.find '[name="credit_card['+field+']"]'
      input = if input.length then input else null

      return true if !input

      input.addClass @config.inputErrorClass
      label = input.siblings('label')
      if label.length is 0 then label = input.closest('label')
      label.addClass @config.labelErrorClass
      @form.trigger 'error-shown', [input, message.text]

    showErrorSummary: (event, messages) =>
      errors = []
      for message in messages
        errors.push "<li>#{message.text}</li>"

      # Make sure the errors are unique'd
      errors = $.grep errors, (v, k) => $.inArray(v, errors) == k

      errorContainerHTML = "<div class=\"#{@config.errorSummaryClass}\">
        <strong>#{PaymentErrorRenderer.ERROR_MESSAGES.summary_header}</strong>
        <ul>#{errors.join('')}</ul>
      </div>"

      @form
        .find('.'+@config.errorSummaryClass).remove().end()
        .find('[type="submit"]').last()
          .before(errorContainerHTML)
    
    # Clears all errors and wipes the internal error message array.
    reset: =>
      @form
        .find('.'+@config.inputErrorClass).removeClass(@config.inputErrorClass).end()
        .find('.'+@config.labelErrorClass).removeClass(@config.labelErrorClass).end()
        .find('.'+@config.errorSummaryClass).remove()

    # Detaches event listeners and destroys this renderer.
    destroy: ->
      @form
        .unbind('submit', @reset)
        .unbind('error', @highlightFieldWithErrors)
        .unbind('errors', @showErrorSummary)

      PaymentErrorRenderer.errorRenderers = $.grep PaymentErrorRenderer.errorRenderers, (r) => r[1] != this 
      @form = null

