require 'rubygems'
require "test/unit"
require 'selenium-webdriver'
require 'capybara'
require 'capybara/dsl'
require 'active_support/core_ext/string/inflections'
require 'support/samurai_js_tests'


tests = [
  {:browser => :chrome, :version => nil, :platform => :VISTA },
  {:browser => :chrome, :version => nil, :platform => :XP },
  {:browser => :chrome, :version => nil, :platform => :LINUX },
  {:browser => :firefox, :version => '9', :platform => :XP },
  {:browser => :firefox, :version => '9', :platform => :VISTA },
  {:browser => :firefox, :version => '9', :platform => :LINUX },
  {:browser => :firefox, :version => '8', :platform => :XP },
  {:browser => :firefox, :version => '7', :platform => :XP },
  {:browser => :internet_explorer, :version => '9', :platform => :VISTA },
  {:browser => :internet_explorer, :version => '8', :platform => :XP },
  {:browser => :internet_explorer, :version => '7', :platform => :XP },
]

revision = `git rev-parse HEAD`

tests.each do |specs|

  name = "#{specs[:browser].to_s.camelcase}#{specs[:version]}#{specs[:platform].to_s.downcase.camelcase}"
  klass_name = "#{name}Test".classify
  klass = Object.const_set(klass_name, Class.new(Test::Unit::TestCase))

  klass.class_eval <<-__RUBY__
    include Capybara::DSL

    def setup
      @caps = Selenium::WebDriver::Remote::Capabilities.send("#{specs[:browser]}")
      @caps.platform = :#{specs[:platform]}
      @caps[:name] = "Samurai.js Integration Test - #{specs[:browser].to_s.titleize} #{specs[:version]}, #{specs[:platform]}"
      @caps[:tags] = [ "#{revision}", "#{specs[:browser]}", "#{specs[:platform]}", "#{name}" ]

      Capybara.run_server = false
      Capybara.register_driver :#{name} do |app|
        Capybara::Selenium::Driver.new(app, {
          :browser => :remote,
          :url => "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_ACCESS_KEY']}@ondemand.saucelabs.com:80/wd/hub",
          :desired_capabilities => @caps,
        })
      end
      Capybara.current_driver = :#{name}
    end

    include SamuraiJsTests
  __RUBY__

end
