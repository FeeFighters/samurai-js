# Module for observing the credit_card[number] field, and displaying the proper card images
$ = jQuery

@module "Samurai", ->
  @ExpirationDates = do ->
    yearSelect = null

    init = ->
      monthSelect = $("select[name='credit_card[expiry_month]']")
      yearSelect = $("select[name='credit_card[expiry_year]']")
      $ =>
        hideExpiredOptions()

    hideExpiredOptions = ->
      date = new Date()
      year = date.getFullYear()
      yearSelect.children('option').filter (option) ->
        parseInt(this.value) < year
      .remove()

    # Export public API
    {init}