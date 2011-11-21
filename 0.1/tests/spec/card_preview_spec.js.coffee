$ = Samurai.jQuery

describe "card_preview", ->

  beforeEach ->
    jasmine.getFixtures().set '''
<label for="credit_card_card_number">Card Number</label>
<input id="credit_card_card_number" name="credit_card[card_number]" size="30" type="text" value="" />
<label data-samurai-card-previews>
  <span class='visa'></span>
  <span class='mastercard'></span>
  <span class='amex'></span>
  <span class='discover'></span>
  <span class='diners_club'></span>
  <span class='unknown active'></span>
</label>
'''
    Samurai.CardPreview.init()

  describe "on init", ->
    it "should clear the current active class", ->
      expect($('span.unknown')).not.toHaveClass('active');

  describe "when the user begins typing in a visa card", ->
    it "should set the active class, on keyup", ->
      $('#credit_card_card_number').val('411').keyup()
      expect($('span.visa')).toHaveClass('active');
    it "should set the active class, on change", ->
      $('#credit_card_card_number').val('411').change()
      expect($('span.visa')).toHaveClass('active');
    it "should clear the current active class, on keyup", ->
      $('span.unknown').addClass 'active'
      $('#credit_card_card_number').val('411').keyup()
      expect($('span.unknown')).not.toHaveClass('active');
    it "should clear the current active class, on change", ->
      $('span.unknown').addClass 'active'
      $('#credit_card_card_number').val('411').change()
      expect($('span.unknown')).not.toHaveClass('active');

  describe "when the user types in a visa card", ->
    it "should set the active class", ->
      $('#credit_card_card_number').val('4111111111111111').change()
      expect($('span.visa')).toHaveClass('active');

  describe "when the user types in a mastercard card", ->
    it "should set the active class", ->
      $('#credit_card_card_number').val('5111111111111118').change()
      $('#credit_card_card_number').change()
      expect($('span.mastercard')).toHaveClass('active');

  describe "when the user types in a amex card", ->
    it "should set the active class", ->
      $('#credit_card_card_number').val('378282246310005').change()
      $('#credit_card_card_number').change()
      expect($('span.amex')).toHaveClass('active');

  describe "when the user types in a discover card", ->
    it "should set the active class", ->
      $('#credit_card_card_number').val('6011111111111117').change()
      expect($('span.discover')).toHaveClass('active');

  describe "when the user types in a diners card", ->
    it "should set the active class", ->
      $('#credit_card_card_number').val('38520000023237').change()
      expect($('span.diners_club')).toHaveClass('active');

