require 'rubygems'
require File.join(File.dirname(__FILE__), 'user.rb')

@@userIndex = 0;
def userId
	sprintf("10%03d%03d", rand(1000), @@userIndex += 1).to_i
end

threads =[]
# 100.times do 
# 	threads << Thread.new do
# 		NonActiveUser.new(userId()).doWork()
# 	end 
# end

20.times do 
	threads << Thread.new do
		PotentialUser.new(userId()).doWork()
	end 
end
# 10.times do 
# 	threads << Thread.new do
# 		ActiveUser.new(userId()).doWork()
# 	end
# end
# 8.times do 
# 	threads << Thread.new do
# 		VerifyActiveUser.new(userId()).doWork()
# 	end
# end
# t1.join
threads.each {|t| t.join}
#User.new(1235).do([{view:[1,2,3], action:{carted:[1], addOrder:[1], confirmOrder:[1], paid:[1]}}])

#[InActiveUser.new(1234), InActiveUser.new(1235)].startShopping();
#[InActiveUser.new(1234), InActiveUser.new(1235)].startShopping();
