$ = Samurai.jQuery

describe "payment_error_handler", ->

  testPaymentErrorHandler = null
  test_form = null

  beforeEach ->
    jasmine.getFixtures().set '''
<form action="/samurai-rocks" method="POST" id="test_form">
  <input id="credit_card_card_number" name="credit_card[card_number]" size="30" type="text" value="" autocomplete="off" />
  <input id="credit_card_cvv" name="credit_card[cvv]" size="30" type="text" value="" autocomplete="off" />
</form>
'''
    test_form = $('#test_form')
    testPaymentErrorHandler = Samurai.PaymentErrorHandler.for(test_form)


  describe "on init", ->
    it "should find the cached payment error handler", ->
      expect(testPaymentErrorHandler).toEqual Samurai.PaymentErrorHandler.for(test_form)

  describe "handling a payment event", ->
    describe "if there are messages", ->
      it "should handle the error messages", ->
        spyOn(testPaymentErrorHandler, 'handleErrorsFromResponse')
        response =
          transaction:
            processor_response:
              messages: [
                { subclass:'error', context:'processor.transaction', key:'declined'}
              ]
        testPaymentErrorHandler.handlePaymentEvent {}, response
        expect(testPaymentErrorHandler.handleErrorsFromResponse).toHaveBeenCalledWith(response)

    describe "if there are no messages", ->
      it "should not handle the error messages", ->
        spyOn(testPaymentErrorHandler, 'handleErrorsFromResponse')
        response =
          transaction:
            processor_response:
              messages: []
        testPaymentErrorHandler.handlePaymentEvent {}, response
        expect(testPaymentErrorHandler.handleErrorsFromResponse).not.toHaveBeenCalled()

    describe "if messages does not exist", ->
      it "should not handle the error messages", ->
        spyOn(testPaymentErrorHandler, 'handleErrorsFromResponse')
        response = transaction: {}
        testPaymentErrorHandler.handlePaymentEvent {}, response
        expect(testPaymentErrorHandler.handleErrorsFromResponse).not.toHaveBeenCalled()


  describe 'handling response error messages', ->
    response = messages = test_form = null

    describe 'with error messages', ->
      beforeEach ->
        response =
          transaction:
            processor_response:
              messages: [
                { subclass:'error', context:'input.card_number', key:'is_blank'}
                { subclass:'error', context:'input.card_number', key:'not_numeric'}
                { subclass:'error', context:'input.card_number', key:'too_short'}
                { subclass:'error', context:'input.cvv', key:'is_blank'}
                { subclass:'error', context:'processor.transaction', key:'declined'}
                { subclass:'info',  context:'processor.avs_result_code', key:'0'}
                { subclass:'info',  context:'processor.cvv_result_code', key:'0'}
              ]
        messages = response.transaction.processor_response.messages
        test_form = testPaymentErrorHandler.form

      it 'should trigger the show-error event on the form for each error', ->
        spyOn(test_form, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(test_form.trigger).toHaveBeenCalledWith 'show-error', [$('[name="credit_card[card_number]"]'), 'is required.', messages[0]]
        expect(test_form.trigger).toHaveBeenCalledWith 'show-error', [$('[name="credit_card[cvv]"]'), 'is required.', messages[3]]
        expect(test_form.trigger).toHaveBeenCalledWith 'show-error', [null, 'Your card was declined.', messages[4]]

      it 'should trigger the errors-shown event on the form', ->
        spyOn(test_form, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(test_form.trigger).toHaveBeenCalledWith 'errors-shown', [[messages[4], messages[0], messages[3]]]

      describe 'with redundant events', ->
        it 'should trigger for is_blank only', ->
          response.transaction.processor_response.messages = messages = [
            { subclass:'error', context:'input.card_number', key:'not_numeric'}
            { subclass:'error', context:'input.card_number', key:'is_blank'}
            { subclass:'error', context:'input.card_number', key:'too_short'}
            { subclass:'error', context:'input.card_number', key:'too_long'}
            { subclass:'error', context:'input.card_number', key:'failed_checksum'}
          ]
          spyOn(test_form, 'trigger')
          testPaymentErrorHandler.handleErrorsFromResponse response
          expect(test_form.trigger).toHaveBeenCalledWith 'show-error', [$('[name="credit_card[card_number]"]'), 'is required.', messages[1]]
          expect(test_form.trigger).toHaveBeenCalledWith 'errors-shown', [[messages[1]]]
          expect(test_form.trigger.calls.length).toEqual(2)

        it 'should trigger for not_numeric only', ->
          response.transaction.processor_response.messages = messages = [
            { subclass:'error', context:'input.card_number', key:'too_short'}
            { subclass:'error', context:'input.card_number', key:'too_long'}
            { subclass:'error', context:'input.card_number', key:'not_numeric'}
            { subclass:'error', context:'input.card_number', key:'failed_checksum'}
          ]
          spyOn(test_form, 'trigger')
          testPaymentErrorHandler.handleErrorsFromResponse response
          expect(test_form.trigger).toHaveBeenCalledWith 'show-error', [$('[name="credit_card[card_number]"]'), 'must be a number.', messages[2]]
          expect(test_form.trigger).toHaveBeenCalledWith 'errors-shown', [[messages[2]]]
          expect(test_form.trigger.calls.length).toEqual(2)

        it 'should trigger for too_short only', ->
          response.transaction.processor_response.messages = messages = [
            { subclass:'error', context:'input.card_number', key:'too_long'}
            { subclass:'error', context:'input.card_number', key:'failed_checksum'}
            { subclass:'error', context:'input.card_number', key:'too_short'}
          ]
          spyOn(test_form, 'trigger')
          testPaymentErrorHandler.handleErrorsFromResponse response
          expect(test_form.trigger).toHaveBeenCalledWith 'show-error', [$('[name="credit_card[card_number]"]'), 'is too short.', messages[2]]
          expect(test_form.trigger).toHaveBeenCalledWith 'errors-shown', [[messages[2]]]
          expect(test_form.trigger.calls.length).toEqual(2)

        it 'should trigger for too_long only', ->
          response.transaction.processor_response.messages = messages = [
            { subclass:'error', context:'input.card_number', key:'failed_checksum'}
            { subclass:'error', context:'input.card_number', key:'too_long'}
          ]
          spyOn(test_form, 'trigger')
          testPaymentErrorHandler.handleErrorsFromResponse response
          expect(test_form.trigger).toHaveBeenCalledWith 'show-error', [$('[name="credit_card[card_number]"]'), 'is too long.', messages[1]]
          expect(test_form.trigger).toHaveBeenCalledWith 'errors-shown', [[messages[1]]]
          expect(test_form.trigger.calls.length).toEqual(2)

        it 'should trigger for failed_checksum only', ->
          response.transaction.processor_response.messages = messages = [
            { subclass:'error', context:'input.card_number', key:'failed_checksum'}
          ]
          spyOn(test_form, 'trigger')
          testPaymentErrorHandler.handleErrorsFromResponse response
          expect(test_form.trigger).toHaveBeenCalledWith 'show-error', [$('[name="credit_card[card_number]"]'), 'is not valid.', messages[0]]
          expect(test_form.trigger).toHaveBeenCalledWith 'errors-shown', [[messages[0]]]
          expect(test_form.trigger.calls.length).toEqual(2)


      it 'should trigger the default unknown error if the message is not recognized', ->
        response.transaction.processor_response.messages = messages = [
          { subclass:'error', context:'abc', key:'123'}
        ]
        spyOn(test_form, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(test_form.trigger).toHaveBeenCalledWith 'show-error', [null, 'An unknown error occurred. Please contact support.', messages[0]]

      it 'should not trigger show-error if only info messages are found', ->
        response.transaction.processor_response.messages = messages = [
          { subclass:'info',  context:'processor.avs_result_code', key:'0'}
          { subclass:'info',  context:'processor.cvv_result_code', key:'0'}
        ]
        spyOn(test_form, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(test_form.trigger).not.toHaveBeenCalled()

      it 'should trigger the proper responses with a processor.configuration error', ->
        response.transaction.processor_response.messages = messages = [
          { "context":"processor.configuration",   "key":"invalid",  "subclass":"error" }
          { "context":"processor.avs_result_code", "key":"B",        "subclass":"info" }
        ]
        spyOn(test_form, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(test_form.trigger).toHaveBeenCalledWith 'show-error', [null, 'This processor is not configured properly. Please contact support.', messages[0]]

      it 'should trigger the proper responses with a processor.transaction invalid error', ->
        response.transaction.processor_response.messages = messages = [
          { "context":"processor.transaction",      "key":"invalid",  "subclass":"error" }
          { "context":"processor.avs_result_code",  "key":"B",        "subclass":"info" }
        ]
        spyOn(test_form, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(test_form.trigger).toHaveBeenCalledWith 'show-error', [null, 'This transaction is invalid. Please contact support.', messages[0]]

      it 'should trigger the proper responses with a processor.transaction declined error', ->
        response.transaction.processor_response.messages = messages = [
          { "context":"processor.transaction",      "key":"declined",   "subclass":"error" }
          { "context":"processor.avs_result_code",  "key":"B",          "subclass":"info" }
        ]
        spyOn(test_form, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(test_form.trigger).toHaveBeenCalledWith 'show-error', [null, 'Your card was declined.', messages[0]]

      it 'should trigger the proper responses with a processor.transaction duplicate error', ->
        response.transaction.processor_response.messages = messages = [
          { "context":"processor.transaction",      "key":"duplicate",  "subclass":"error" }
          { "context":"processor.avs_result_code",  "key":"B",          "subclass":"info" }
        ]
        spyOn(test_form, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(test_form.trigger).toHaveBeenCalledWith 'show-error', [null, 'Duplicate transaction detected. This transaction was not processed.', messages[0]]
