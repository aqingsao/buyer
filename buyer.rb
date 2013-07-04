require 'rubygems'
require File.join(File.dirname(__FILE__), 'user.rb')

@@userIndex = 0;
def userId
	sprintf("10%03d%03d", rand(1000), @@userIndex += 1).to_i
end

threads =[]
200.times do 
	threads << Thread.new do
		NonActiveUser.new(userId(), 'nonActive').doWork()
	end 
end
50.times do 
	threads << Thread.new do
		LittleActiveUser.new(userId(), 'littleActive').doWork()
	end 
end

30.times do 
	threads << Thread.new do
		PotentialUser.new(userId(), 'potential').doWork()
	end 
end
10.times do 
	threads << Thread.new do
		ActiveUser.new(userId(), 'active').doWork()
	end
end
10.times do 
	threads << Thread.new do
		VerifyActiveUser.new(userId(), 'veryActive').doWork()
	end
end
threads.each {|t| t.join}
#User.new(1235).do([{view:[1,2,3], action:{carted:[1], addOrder:[1], confirmOrder:[1], paid:[1]}}])

#[InActiveUser.new(1234), InActiveUser.new(1235)].startShopping();
#[InActiveUser.new(1234), InActiveUser.new(1235)].startShopping();
