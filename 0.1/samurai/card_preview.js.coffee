# Module for observing the credit_card[number] field, and displaying the proper card images
$ = jQuery

@module "Samurai", ->
  @CardPreview = do ->
    cardNumberField = []
    cardPreviews = null
    showAccepted = true

    init = ->
      cardNumberField = $("input[name='credit_card[card_number]']")
      if cardNumberField.length
        attachEventHandlers()
        $ =>
          cardPreviews = null
          cacheCardPreviews()
          clearCardPreviews()
          checkCardForPreview()

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

    cacheCardPreviews = ->
      cardPreviews = $('[data-samurai-card-previews] span') unless cardPreviews?

    checkCardForPreview = ->
      cardBrand = Samurai.Utilities.cardBrandFromNumber cardNumberField.val()
      previewCard(cardBrand) if cardBrand

    clearCardPreviews = ->
      cardPreviews.removeClass 'active'

    previewCard = (card) ->
      cardPreviews.filter('.'+card).addClass 'active'

    fadeAcceptedCards = ->
      $('[data-samurai-card-previews]').removeClass 'show-accepted'
      showAccepted = false

    # Export public API
    {init}
