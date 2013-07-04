require 'rubygems'
require File.join(File.dirname(__FILE__), 'user.rb')

threads =[
	Thread.new do
		NonActiveUser.new(1230).doWork()
	end, 
	Thread.new do
		PotentialUser.new(1231).doWork()
	end, 
	Thread.new do
		ActiveUser.new(1232).doWork()
	end, 
	Thread.new do
		VerifyActiveUser.new(1233).doWork()
	end
]
# t1.join
threads.each {|t| t.join}
#User.new(1235).do([{view:[1,2,3], action:{carted:[1], addOrder:[1], confirmOrder:[1], paid:[1]}}])

#[InActiveUser.new(1234), InActiveUser.new(1235)].startShopping();
#[InActiveUser.new(1234), InActiveUser.new(1235)].startShopping();
