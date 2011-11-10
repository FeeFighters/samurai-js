# Samurai Expiration Dates Module
# ------------------------

$ = jQuerySamurai

# Module for adjusting expiration-date selectors to make them more user-friendly
# _WIP!_
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