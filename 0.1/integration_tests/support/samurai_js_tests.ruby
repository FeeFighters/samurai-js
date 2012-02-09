module SamuraiJsTests

  def test_sauce
    Capybara.app_host = "http://examples.samurai.feefighters.com/sinatra/samurai_js"

    visit '/payment_form'
    assert_equal true, page.has_content?('Enter your payment information:')

    # First submit it empty
    click_button 'Submit Payment'
    assert_not_nil find('.error-summary').text =~ /The card number was blank/

    # Then fill out a successful tx
    fill_in('First name', :with => 'John')
    fill_in('Last name', :with => 'Doe')
    fill_in('Address 1', :with => '1000 1st Av')
    fill_in('City', :with => 'Chicago')
    fill_in('State', :with => 'IL')
    fill_in('Zip', :with => '10101')
    fill_in('Card number', :with => '4111111111111111')
    fill_in('CVV', :with => '111')
    select('05', :from => 'credit_card_expiry_month')
    select('2015', :from => 'credit_card_expiry_year')

    click_button 'Resubmit Payment'
    assert_equal true, page.has_content?('Your purchase has been completed')
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.current_session.driver.quit
    Capybara.use_default_driver
  end

  private

  def select_option(select_elem, value)
    select_elem.click
    select_elem.find_elements( :tag_name => "option" ).find do |option|
      option.text == value
    end.click
  end

end
