$ = Samurai.jQuery

describe "payment_forms", ->

  describe "with multiple forms", ->
    beforeEach ->
      jasmine.getFixtures().set '''
  <div data-samurai-payment-form class=''></div>
  <div data-samurai-payment-form class='samurai-placeholders'></div>
  <div data-samurai-payment-form class='samurai-placeholders samurai-wide'></div>
  '''
    describe "on init", ->
      it "should add a form to any data-samurai-payment-form", ->
        Samurai.PaymentForms.init()
        expect($('form').length).toEqual 3

  describe "with a standard form", ->
    beforeEach ->
      jasmine.getFixtures().set "<div data-samurai-payment-form class=''></div>"
    describe "on init", ->
      beforeEach ->
        Samurai.PaymentForms.init()
      it "should build a form with the default template", ->
        expect($('form')).toHaveClass('samurai')
        expect($('form input[placeholder]')).not.toExist()
      it "should build an ajax-enabled form", ->
        expect($('form')).toHaveAttr('data-samurai-ajax')

  describe "with a standard form with a wide style", ->
    beforeEach ->
      jasmine.getFixtures().set "<div data-samurai-payment-form class='samurai-wide'></div>"
    describe "on init", ->
      beforeEach ->
        Samurai.PaymentForms.init()
      it "should build a form with the default template", ->
        expect($('form')).toHaveClass('samurai')
        expect($('form input[placeholder]')).not.toExist()

  describe "with a placeholder form", ->
    beforeEach ->
      jasmine.getFixtures().set "<div data-samurai-payment-form class='samurai-placeholders'></div>"
    describe "on init", ->
      beforeEach ->
        Samurai.PaymentForms.init()
      it "should build a form with the placeholder template", ->
        expect($('form')).toHaveClass('samurai')
        expect($('form input[placeholder]')).toExist()
      it "should build an ajax-enabled form", ->
        expect($('form')).toHaveAttr('data-samurai-ajax')

  describe "with a placeholder form with a wide style", ->
    beforeEach ->
      jasmine.getFixtures().set "<div data-samurai-payment-form class='samurai-placeholders samurai-wide'></div>"
    describe "on init", ->
      beforeEach ->
        Samurai.PaymentForms.init()
      it "should build a form with the default template", ->
        expect($('form')).toHaveClass('samurai')
        expect($('form input[placeholder]')).toExist()

