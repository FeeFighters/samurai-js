$ = Samurai.jQuery

describe "payment_error_renderer", ->

  testPaymentErrorRenderer = null
  testPaymentErrorHandler = null
  testForm = null
  messages = null
  response = null

  beforeEach ->
    jasmine.getFixtures().set '''
<form action="/samurai-rocks" method="POST" id="testForm">
  <input id="credit_card_card_number" name="credit_card[card_number]" size="30" type="text" value="" autocomplete="off" />
  <input id="credit_card_cvv" name="credit_card[cvv]" size="30" type="text" value="" autocomplete="off" />
  <input type="submit" />
</form>
'''
    testForm = $('#testForm')
    testPaymentErrorHandler = Samurai.PaymentErrorHandler.forForm(testForm)
    testPaymentErrorRenderer = Samurai.PaymentErrorRenderer.forForm(testForm)
    response = {
      messages: [
        { subclass:  'error', context:  'input.card_number', key:      'is_blank'}
        { subclass:  'error', context:  'input.cvv', key:              'is_blank'}
        { subclass:  'error', context:  'processor.transaction', key:  'declined'}
        { subclass:  'error', context:  'abc', key:                    '123'}
        { subclass:  'error', context:  'def', key:                    '456'}
      ] }
    messages = testPaymentErrorHandler.extractErrorMessagesFromResponse(response)

  describe "on init", ->
    it "should find the cached payment error renderer", ->
      expect(testPaymentErrorRenderer).toEqual Samurai.PaymentErrorRenderer.forForm(testForm)

  describe 'on error', ->
    it 'should highlight the erroneous field', ->
      testForm.trigger 'error', [messages[0]]
      expect(testForm.find('[name="credit_card[card_number]"]').hasClass('error')).toBe(true)

  describe 'showing error summary', ->
    it 'should add a error summary div', ->
      testPaymentErrorRenderer.showErrorSummary null, messages
      expect(testForm).toContain '.error-summary'

    it 'should add an li for each error', ->
      testPaymentErrorRenderer.showErrorSummary null, messages
      expect(testForm.find('.error-summary li').length).toEqual 4
      expect(testForm.find('.error-summary li')).toHaveText /card number was blank/
      expect(testForm.find('.error-summary li')).toHaveText /CVV was blank/
      expect(testForm.find('.error-summary li')).toHaveText /card was declined/
      expect(testForm.find('.error-summary li')).toHaveText /An unknown error occurred. Please contact support./
