# Samurai Card Previews Module
# ------------------------
$ = Samurai.jQuery

# Module for observing the credit_card[number] field, and displaying the proper card images
@module "Samurai", ->
  @CardPreview = do ->
    cardNumberField = []
    cardPreviews = null
    showAccepted = true

    # Initialize the module
    # Attach event handlers on jQuery.ready()
    # Build & display the card preview images
    init = ->
      cardNumberField = $("input[name='credit_card[card_number]']")
      if cardNumberField.length
        attachEventHandlers()
        $ =>
          cardPreviews = null
          cacheCardPreviews()
          clearCardPreviews()
          checkCardForPreview()

    # Attach event handlers to the form fields
    attachEventHandlers = ->
      cardNumberField.keyup =>
        fadeAcceptedCards() if showAccepted
        clearCardPreviews()
        checkCardForPreview()
        true
      cardNumberField.change =>
        clearCardPreviews()
        checkCardForPreview()
        true

    # Cache the card preview elements, so we aren't looking them up every time
    cacheCardPreviews = ->
      cardPreviews = $('[data-samurai-card-previews] span') unless cardPreviews?

    # Check if the card number matches a brand, and display that brand
    checkCardForPreview = ->
      cardBrand = Samurai.Utilities.cardBrandFromNumber cardNumberField.val()
      previewCard(cardBrand) if cardBrand

    # Clear the displayed card brand
    clearCardPreviews = ->
      cardPreviews.removeClass 'active'

    # Display a specific card brand
    previewCard = (card) ->
      cardPreviews.filter('.'+card).addClass 'active'

    # Fade out the card images (once the user starts typing)
    fadeAcceptedCards = ->
      $('[data-samurai-card-previews]').removeClass 'show-accepted'
      showAccepted = false

    # Export public API
    {init}
