# Samurai.js Library Initialization
# --------------------------------------------

# Require each of the modules, using Sprockets
#= require 'api/0.1/samurai/base'
#= require 'api/0.1/samurai/utilities'
#= require 'api/0.1/samurai/events'
#= require 'api/0.1/samurai/card_preview'
#= require 'api/0.1/samurai/expiration_dates'
#= require 'api/0.1/samurai/payments'
#= require 'api/0.1/samurai/payment_error_handler'
#= require 'api/0.1/samurai/payments_legacy_events'
#= require 'api/0.1/samurai/payment_forms'

# Initializes each of the Samurai modules
#
# This is called by the bootloader's .init() function,
# once the full Samurai.js library is loaded on the page
@Samurai.init = (@config={})->
  Samurai.log 'Bootstrapped. Initializing, with config:'
  Samurai.log @config

  # Initialize Samurai modules!
  Samurai.PaymentForms.init()
  Samurai.CardPreview.init()
  Samurai.ExpirationDates.init()
  Samurai.Payments.init()
  Samurai.PaymentsLegacyEvents.init()

  # Override the .ready() command, since we're ready, we want to immediate trigger the callback
  @ready = (callback) -> callback()

  # Trigger the ready() callbacks
  for callback in @readyCallbacks
    callback()
  true


