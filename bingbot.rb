#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "capybara"
require "capybara/dsl"
require 'capybara/poltergeist'
require "yaml"
require "pry"
require 'literate_randomizer'
Capybara.run_server = false
Capybara.app_host = "http://www.bing.com"
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {js_errors: false})
end
Capybara.current_driver = :poltergeist
Capybara.default_wait_time = 15
CONFIG = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)),"config.yml")) unless defined? CONFIG

module Bing
  class Bing_bot
    include Capybara::DSL

    def log_in 
      puts 'Signing in'
      within 'div.signInOptions' do
        first(:link, 'Sign in').click
      end
      page.has_text? 'Sign in'
      fill_in "login", :with=>CONFIG['BING_USERNAME']
      fill_in "passwd", :with=>CONFIG['BING_PASSWORD']
      find(:xpath, "//input[@id='idSIButton9']").click
    end

    def visit_rewards_dash
      visit 'https://www.bing.com/rewards/dashboard'
      page.has_text? 'Bing Rewards'
      page.has_text? 'Dashboard'
      log_in if page.has_text? 'You are not signed in to Bing Rewards.'
    end

    def check_mobile_points
      visit_rewards_dash
      puts 'Checking Mobile search points'
      mobile_search_div = find('li', text: 'Mobile search')
      if mobile_search_div.has_selector? 'div.close-check'
        puts 'Mobile points completed!'
        @mobile_completed = @mobile_available = mobile_search_div.find('div.progress').text.match(/^(\d*) credits$/)[1].to_i
      else
        matches = mobile_search_div.find('div.progress').text.match(/^(\d*) of (\d*) credits$/)
        @mobile_completed = matches[1].to_i
        @mobile_available = matches[2].to_i
      end

    end

    def check_pc_points
      puts 'Checking Pc search points'
      visit_rewards_dash
      pc_search_div = find('li', text: 'PC search')
      if pc_search_div.has_selector? 'div.close-check'
        puts 'PC points completed'
        @pc_completed = @pc_available = pc_search_div.find('div.progress').text.match(/^(\d*) credits$/)[1].to_i
      else
        matches = pc_search_div.find('div.progress').text.match(/^(\d*) of (\d*) credits$/)
        @pc_completed = matches[1].to_i
        @pc_available = matches[2].to_i
      end
    end

    def get_bonus_points
      #TODO
      #click on daily offers
      #find('div.tileset', text: 'Earn and explore').click
    end

    def do_mobile_searches
      page.driver.headers = {"User-Agent" => "Mozilla/5.0 (Linux; Android 4.1.1; Galaxy Nexus Build/JRO03C) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19"}
      puts 'Starting Mobile Searches'
      do_search (@mobile_available - @mobile_completed) * 2
    end

    def do_pc_searches
      page.driver.headers = {"User-Agent" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.45 Safari/535.19"}
      puts 'Starting Pc Searches'
      do_search (@pc_available - @pc_completed) * 2
    end

    def do_search searches
      searches.times do |i| #do 120 to 140 searchs per day
        count = Random.new.rand(1..5) #wait 15s - 2mins per search
        count.times do
          STDOUT.write "\rSearch:  #{i+1} of #{searches}"
          sleep 1
          count-=1
        end
        visit("https://www.bing.com/search?q=#{LiterateRandomizer.word}&go=Submit&qs=bs&form=QBRE")
      end
      puts "...Done"
    end


    def start
      check_mobile_points
      check_pc_points
      do_mobile_searches
      do_pc_searches
    end

  end
end

begin
  bot = Bing::Bing_bot.new
  bot.start
rescue Interrupt
  STDOUT.write "\nGood bye...\n"
end
