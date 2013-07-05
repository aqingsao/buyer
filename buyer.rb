require 'rubygems'
require File.join(File.dirname(__FILE__), 'user.rb')
require File.join(File.dirname(__FILE__), 'util.rb')
include Util

@@userIndex = 0;
def userId
	sprintf("10%03d%03d", rand(1000), @@userIndex += 1).to_i
end

threads =[]
NonActiveCount = 202;
LittleActiveCount = 58
PotentialCount = 31
ActiveCount = 13
VeryActiveCount = 11


@@nonActive = 0
@@littleActive = 0
@@potential = 0
@@active = 0
@@veryActive = 0

def notFinished
	@@nonActive < NonActiveCount || @@littleActive < LittleActiveCount  || @@potential < PotentialCount  || @@active < ActiveCount || @@veryActive < VeryActiveCount
end

class Users
	attr_reader :threads

	def initialize(type, count, userIntervalRange)
		@type = type
		@count = count
		@userIntervalRange = userIntervalRange
		@threads = []
	end

	def doWork
		begin
			@threads << Thread.new do
				User.method(@type).call(userId()).doWork()
				p "create #{@type} user"
			end
			sleepFor(@userIntervalRange.first, @userIntervalRange.last)
		end while @threads.length < @count
		@threads.each{|t| t.join}
	end
end

[Thread.new do
	users1 = Users.new('nonActive', 5, 1..5);
	users1.doWork
	# users1.threads.each {|t| t.join}
end, 
Thread.new do
	users = Users.new('active', 5, 1..5);
	users.doWork
	# users.threads.each {|t| t.join}
end
].each{|t| t.join}

# begin
# 	nonActive = @@nonActive < NonActiveCount ? count(3, 4) : 0;
# 	nonActive.times do 
# 		threads << Thread.new do
# 			User.nonActiveUser(userId()).doWork()
# 		end 
# 		Util.sleepFor(5, 15)
# 	end
# 	@@nonActive += nonActive
# 	p "create #{nonActive} nonActive users with total #{@@nonActive}"

# 	littleActive = @@littleActive < LittleActiveCount ? count(2, 3) : 0;
# 	littleActive.times do 
# 		threads << Thread.new do
# 			User.littleActiveUser(userId()).doWork()
# 		end 
# 		Util.sleepFor(5, 15)
# 	end
# 	@@littleActive += littleActive
# 	p "create #{littleActive} littleActive users with total #{@@littleActive}"

# 	potential = @@potential < PotentialCount ? count(1, 2) : 0;
# 	potential.times do 
# 		threads << Thread.new do
# 			User.potentialUser(userId()).doWork()
# 		end 
# 		Util.sleepFor(5, 15)
# 	end
# 	@@potential += potential
# 	p "create #{potential} potential users with total #{@@potential}"

# 	active = @@active < ActiveCount ? count(1, 1) : 0;
# 	active.times do 
# 		threads << Thread.new do
# 			User.activeUser(userId()).doWork()
# 		end 
# 		Util.sleepFor(5, 15)
# 	end
# 	@@active += active
# 	p "create #{active} active users with total #{@@active}"

# 	veryActive = @@veryActive < VeryActiveCount ? count(1, 1) : 0;
# 	veryActive.times do 
# 		threads << Thread.new do
# 			User.veryActiveUser(userId()).doWork()
# 		end 
# 		Util.sleepFor(5, 15)
# 	end
# 	@@veryActive += veryActive
# 	p "create #{veryActive} veryActive users with total #{@@veryActive}"
# end while notFinished()

# threads.each {|t| t.join}