# General utilities module
$ = jQuery

@module "Samurai", ->
  @Utilities = do ->

    cardBrandFromNumber = (number) ->
      number = number.toString()
      for own {name, regex} in companies
        if number.match(regex)
          return name

    companies = [
      { name: 'visa',          regex: /^4/ },
      { name: 'mastercard',    regex: /^(51|52|53|54|55)/ },
      { name: 'amex',          regex: /^(34|37)/ },
      { name: 'discover',      regex: /^(6011|62|64|65)/ },
      { name: 'diners_club',   regex: /^(305|36|38)/ },
      { name: 'carte_blanche', regex: /^(300|301|302|303|304|305)/ },
      { name: 'jcb',           regex: /^35/ },
      { name: 'enroute',       regex: /^(2014|2149)/ },
      { name: 'solo',          regex: /^(6334|6767)/ },
      { name: 'switch',        regex: /^(4903|4905|4911|4936|564182|633110|6333|6759)/ },
      { name: 'maestro',       regex: /^(5018|5020|5038|6304|6759|6761)/ },
      { name: 'visa',          regex: /^(417500|4917|4913|4508|4844)/ },   # visa electron
      { name: 'laser',         regex: /^(6304|6706|6771|6709)/ },
    ]

    # Export public API
    {cardBrandFromNumber}
