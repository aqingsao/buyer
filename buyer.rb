require 'rubygems'
require File.join(File.dirname(__FILE__), 'user.rb')

User.new(1234).login()
User.new(1235).shopping([1],{carted:[1], addOrder:[[1]]} )

#[InActiveUser.new(1234), InActiveUser.new(1235)].startShopping();
#[InActiveUser.new(1234), InActiveUser.new(1235)].startShopping();
