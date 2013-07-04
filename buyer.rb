require 'rubygems'
require File.join(File.dirname(__FILE__), 'user.rb')

t1 = Thread.new do
GuestUser.new(1234).doWork()
end
t2 = Thread.new do
ActiveUser.new(1235).doWork()
end
t1.join
t2.join
#User.new(1235).do([{view:[1,2,3], action:{carted:[1], addOrder:[1], confirmOrder:[1], paid:[1]}}])

#[InActiveUser.new(1234), InActiveUser.new(1235)].startShopping();
#[InActiveUser.new(1234), InActiveUser.new(1235)].startShopping();
