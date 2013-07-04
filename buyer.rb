require 'rubygems'
require 'mechanize'
require File.join(File.dirname(__FILE__), 'user.rb')

# ~100 user
User.new(1234).login()

#[InActiveUser.new(1234), InActiveUser.new(1235)].startShopping();
#[InActiveUser.new(1234), InActiveUser.new(1235)].startShopping();
