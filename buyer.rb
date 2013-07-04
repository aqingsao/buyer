require 'rubygems'
require File.join(File.dirname(__FILE__), 'user.rb')

User.new(1234).start([{view:[1], action:{carted:[1]}}, {view:[1,2]}] )
#User.new(1235).start([{view:[1,2,3], carted:[1], addOrder:[1], confirmOrder[1], pay[1]}] )

#[InActiveUser.new(1234), InActiveUser.new(1235)].startShopping();
#[InActiveUser.new(1234), InActiveUser.new(1235)].startShopping();
