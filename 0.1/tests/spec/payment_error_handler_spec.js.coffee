$ = Samurai.jQuery

describe "payment_error_handler", ->

  testPaymentErrorHandler = null
  testForm = null
  messages = null

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


  describe "on init", ->
    it "should find the cached payment error handler", ->
      expect(testPaymentErrorHandler).toEqual Samurai.PaymentErrorHandler.forForm(testForm)

  describe "handling a payment event", ->
    it "should handle the error messages", ->
      spyOn(testPaymentErrorHandler, 'handleErrorsFromResponse').andCallThrough()
      response =
        transaction:
          processor_response:
            messages: [
              { subclass:'error', context:'processor.transaction', key:'declined'}
            ]
      testPaymentErrorHandler.handlePaymentEvent {}, response
      expect(testPaymentErrorHandler.handleErrorsFromResponse).toHaveBeenCalledWith(response)

  describe "parsing the error messages from a response", ->
    describe "if there are messages", ->
      it "should extract them from the response object into an array", ->
        response =
          transaction:
            processor_response:
              messages: [
                { subclass: 'error', context: 'processor.transaction', key: 'declined'}
              ]
        expect(testPaymentErrorHandler.extractErrorMessagesFromResponse(response)).toEqual([
          { subclass: 'error', context: 'processor.transaction', key: 'declined', text: 'The card was declined.' }
        ])

    describe "if there are no messages", ->
      it "should return an empty array", ->
        response =
          transaction:
            processor_response:
              messages: []
        expect(testPaymentErrorHandler.extractErrorMessagesFromResponse(response)).toEqual([])

    describe "if messages does not exist", ->
      it "should return an empty array", ->
        response = transaction: {}
        expect(testPaymentErrorHandler.extractErrorMessagesFromResponse(response)).toEqual([])

  describe 'handling response error messages', ->
    response = messages = parsedMessages = testForm = null

    describe 'with error messages', ->
      beforeEach ->
        response =
          transaction:
            processor_response:
              messages: [
                { subclass:  'error', context:  'input.card_number',         key:  'is_blank'}
                { subclass:  'error', context:  'input.card_number',         key:  'not_numeric'}
                { subclass:  'error', context:  'input.card_number',         key:  'too_short'}
                { subclass:  'error', context:  'input.cvv',                 key:  'is_blank'}
                { subclass:  'error', context:  'processor.transaction',     key:  'declined'}
                { subclass:  'info',  context:  'processor.avs_result_code', key:  '0'}
                { subclass:  'info',  context:  'processor.cvv_result_code', key:  '0'}
              ]
        testForm = testPaymentErrorHandler.form
        messages = testPaymentErrorHandler.extractErrorMessagesFromResponse(response)

      it 'should trigger the error event on the form for each error', ->
        spyOn(testForm, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(testForm.trigger).toHaveBeenCalledWith 'error', [messages[0]]
        expect(testForm.trigger).toHaveBeenCalledWith 'error', [messages[3]]
        expect(testForm.trigger).toHaveBeenCalledWith 'error', [messages[4]]

      it 'should trigger the errors event on the form', ->
        spyOn(testForm, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(testForm.trigger).toHaveBeenCalledWith 'errors', [[messages[4], messages[0], messages[3]]]

      describe 'with redundant events', ->
        it 'should trigger for is_blank only', ->
          response.transaction.processor_response.messages = messages = [
            { subclass:'error', context:'input.card_number', key:'not_numeric'}
            { subclass:'error', context:'input.card_number', key:'is_blank'}
            { subclass:'error', context:'input.card_number', key:'too_short'}
            { subclass:'error', context:'input.card_number', key:'too_long'}
            { subclass:'error', context:'input.card_number', key:'failed_checksum'}
          ]
          spyOn(testForm, 'trigger')
          testPaymentErrorHandler.handleErrorsFromResponse response
          expect(testForm.trigger).toHaveBeenCalledWith 'error', [messages[1]]
          expect(testForm.trigger).toHaveBeenCalledWith 'errors', [[messages[1]]]
          expect(testForm.trigger.calls.length).toEqual(2)

        it 'should trigger for not_numeric only', ->
          response.transaction.processor_response.messages = messages = [
            { subclass:'error', context:'input.card_number', key:'too_short'}
            { subclass:'error', context:'input.card_number', key:'too_long'}
            { subclass:'error', context:'input.card_number', key:'not_numeric'}
            { subclass:'error', context:'input.card_number', key:'failed_checksum'}
          ]
          spyOn(testForm, 'trigger')
          testPaymentErrorHandler.handleErrorsFromResponse response
          expect(testForm.trigger).toHaveBeenCalledWith 'error', [messages[2]]
          expect(testForm.trigger).toHaveBeenCalledWith 'errors', [[messages[2]]]
          expect(testForm.trigger.calls.length).toEqual(2)

        it 'should trigger for too_short only', ->
          response.transaction.processor_response.messages = messages = [
            { subclass:'error', context:'input.card_number', key:'too_long'}
            { subclass:'error', context:'input.card_number', key:'failed_checksum'}
            { subclass:'error', context:'input.card_number', key:'too_short'}
          ]
          spyOn(testForm, 'trigger')
          testPaymentErrorHandler.handleErrorsFromResponse response
          expect(testForm.trigger).toHaveBeenCalledWith 'error', [messages[2]]
          expect(testForm.trigger).toHaveBeenCalledWith 'errors', [[messages[2]]]
          expect(testForm.trigger.calls.length).toEqual(2)

        it 'should trigger for too_long only', ->
          response.transaction.processor_response.messages = messages = [
            { subclass:'error', context:'input.card_number', key:'failed_checksum'}
            { subclass:'error', context:'input.card_number', key:'too_long'}
          ]
          spyOn(testForm, 'trigger')
          testPaymentErrorHandler.handleErrorsFromResponse response
          expect(testForm.trigger).toHaveBeenCalledWith 'error', [messages[1]]
          expect(testForm.trigger).toHaveBeenCalledWith 'errors', [[messages[1]]]
          expect(testForm.trigger.calls.length).toEqual(2)

        it 'should trigger for failed_checksum only', ->
          response.transaction.processor_response.messages = messages = [
            { subclass:'error', context:'input.card_number', key:'failed_checksum'}
          ]
          spyOn(testForm, 'trigger')
          testPaymentErrorHandler.handleErrorsFromResponse response
          expect(testForm.trigger).toHaveBeenCalledWith 'error', [messages[0]]
          expect(testForm.trigger).toHaveBeenCalledWith 'errors', [[messages[0]]]
          expect(testForm.trigger.calls.length).toEqual(2)


      it 'should trigger the default unknown error if the message is not recognized', ->
        response.transaction.processor_response.messages = messages = [
          { subclass:'error', context:'abc', key:'123'}
        ]
        spyOn(testForm, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(testForm.trigger).toHaveBeenCalledWith(
          'error',
          [{
            'context':   'abc',
            'key':       '123',
            'subclass':  'error',
            'text':      'An unknown error occurred. Please contact support.'
          }] )

      it 'should not trigger error if only info messages are found', ->
        response.transaction.processor_response.messages = messages = [
          { subclass:'info',  context:'processor.avs_result_code', key:'0'}
          { subclass:'info',  context:'processor.cvv_result_code', key:'0'}
        ]
        spyOn(testForm, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(testForm.trigger).not.toHaveBeenCalled()

      it 'should trigger the proper responses with a processor.transaction invalid error', ->
        response.transaction.processor_response.messages = messages = [
          { "context":"processor.transaction",      "key":"invalid",  "subclass":"error" }
          { "context":"processor.avs_result_code",  "key":"B",        "subclass":"info" }
        ]
        spyOn(testForm, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(testForm.trigger).toHaveBeenCalledWith(
          'error',
          [{
            'context':   'processor.transaction',
            'key':       'invalid',
            'subclass':  'error',
            'text':      'An unknown error occurred. Please contact support.'
          }] )

      it 'should trigger the proper responses with a processor.transaction declined error', ->
        response.transaction.processor_response.messages = messages = [
          { "context":"processor.transaction",      "key":"declined",   "subclass":"error" }
          { "context":"processor.avs_result_code",  "key":"B",          "subclass":"info" }
        ]
        spyOn(testForm, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(testForm.trigger).toHaveBeenCalledWith(
          'error',
          [{
            'context':   'processor.transaction',
            'key':       'declined',
            'subclass':  'error',
            'text':      'The card was declined.'
          }] )

      it 'should trigger the proper responses with a processor.transaction duplicate error', ->
        response.transaction.processor_response.messages = messages = [
          { "context":"processor.transaction",      "key":"duplicate",  "subclass":"error" }
          { "context":"processor.avs_result_code",  "key":"B",          "subclass":"info" }
        ]
        spyOn(testForm, 'trigger')
        testPaymentErrorHandler.handleErrorsFromResponse response
        expect(testForm.trigger).toHaveBeenCalledWith(
          'error',
          [{
            'context':   'processor.transaction',
            'key':       'duplicate',
            'subclass':  'error',
            'text':      'Duplicate transaction detected. This transaction was not processed.'
          }] )


