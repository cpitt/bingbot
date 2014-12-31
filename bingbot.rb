#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "capybara"
require "capybara/dsl"
require 'capybara/poltergeist'
#require "capybara-webkit"
require "yaml"
require "pry"
#require "random-word"
require 'literate_randomizer'
Capybara.run_server = false
Capybara.app_host = "http://www.bing.com"
Capybara.current_driver = :poltergeist
Capybara.default_wait_time = 15
####Uncomment for and comment out Capybara.current_driver = :webkit for testing
#Capybara.current_driver = :selenium 
#Capybara.register_driver :selenium do |app|
#  Capybara::Selenium::Driver.new(app, :browser => :chrome)
#end
CONFIG = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)),"config.yml")) unless defined? CONFIG
module Bing
  class Bing_bot
    include Capybara::DSL
    def get_results
      page.driver.headers = {'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36'}
      visit('/')
      puts "visiting bing.com"
      sleep 10
      click_on "Sign in" 
      puts "clicking on Sign in"
      sleep 5
      page.all('.b_toggle').first.click #click on the first connect link
      fill_in "login", :with=>CONFIG['BING_USERNAME']
      fill_in "passwd", :with=>CONFIG['BING_PASSWORD']
      sleep 10
      find(:xpath, "//input[@id='idSIButton9']").click
      puts "Signing in"
      sleep 10
      Random.new.rand(120..140).times do |i| #do 120 to 140 searchs per day
        if(i % 4)
          STDOUT.write "\rmobile                              "
          page.driver.headers = {'User-Agent' => 'Mozilla/5.0 (Linux; U; Android 4.0.3; en-us; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30'}
        else
          STDOUT.write "\rweb                              "
          page.driver.headers = {'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36'}
        end
        within "#sb_form" do
          count = Random.new.rand(15..120) #wait 15s - 2mins per search
          count.times do
            STDOUT.write "\rSearch number #{i+1} in #{count} seconds                "
            sleep 1
            count-=1
          end
          STDOUT.write "\rsearching                        "
          #this could probably be done with a query string but might as well just fill it out while we're here
          visit("https://www.bing.com/search?q=#{LiterateRandomizer.word}&go=Submit&qs=bs&form=QBRE")
        end
      end
    end
  end
end
spider = Bing::Bing_bot.new
spider.get_results
