require 'rubygems'
require 'mechanize'
require File.join(File.dirname(__FILE__), 'user.rb')

user = User.new(1234)
user.login