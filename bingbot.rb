#!/usr/bin/ruby
require "rubygems"
require "bundler/setup"
require "capybara"
require "capybara/dsl"
require "capybara-webkit"
require "faker"
require "yaml"
Capybara.run_server = false
Capybara.app_host = "http://www.bing.com"
Capybara.current_driver = :webkit
Capybara.default_wait_time = 5
#Capybara.current_driver = :selenium ###Uncomment for testing
#Capybara.register_driver :selenium do |app|
#  Capybara::Selenium::Driver.new(app, :browser => :chrome)jj
#end

CONFIG = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)),"config.yml")) unless defined? CONFIG
module Test
    class Bing_bot
        include Capybara::DSL
        def get_results
            visit('/')
            puts "visiting bing.com"
            sleep 5
            click_on "Sign in" 
            puts "clicking on Sign in"
            save_screenshot "status.png"
            find(:xpath, "//table[@id='id_dt']/tbody/tr[position() = 2]").click_on('Connect')#click on the second connect link
            save_screenshot "status.png"
            fill_in "login", :with=>CONFIG['BING_USERNAME']
            fill_in "passwd", :with=>CONFIG['BING_PASSWORD']
            save_screenshot "status.png"
            find(:xpath, "//input[@id='idSIButton9']").click
            save_screenshot "status.png"
            puts "Signing in"
            save_screenshot "status.png"
            Random.new.rand(120..140).times do |i| #do 120 to 140 searchs per day
                within "#sb_form" do
                    count = Random.new.rand(15..120)
                    count.times do
                        STDOUT.write "\rSearch number #{i+1} in #{count} seconds                "
                        sleep 1
                        count-=1
                    end
                    STDOUT.write "\rsearching                        "
                    fill_in 'sb_form_q', :with=>Faker::Company.catch_phrase()
                    click_on "sb_form_go"
                end
            end
        end
    end
end

spider = Test::Bing_bot.new
spider.get_results
