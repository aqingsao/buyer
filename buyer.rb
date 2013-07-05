require 'rubygems'
require File.join(File.dirname(__FILE__), 'user.rb')
require File.join(File.dirname(__FILE__), 'util.rb')
include Util

class Users
	@@userIndex = 0;
	attr_reader :threads

	def initialize(type, count, userIntervalRange)
		@type = type
		@count = count
		@userIntervalRange = userIntervalRange
		@threads = []
	end

	def doWork
		begin
			sleepFor(@userIntervalRange.first, @userIntervalRange.last)
			@threads << Thread.new do
				User.method(@type).call(userId()).doWork()
				p "create #{@type} user"
			end
		end while @threads.length < @count
		@threads.each{|t| t.join}
	end
	
	private
	def userId
		sprintf("10%03d%03d", rand(1000), @@userIndex += 1).to_i
	end

end

[Thread.new do
	Users.new('nonActive', 200, 1..5).doWork
end, 
Thread.new do
	users = Users.new('littleActive', 51, 5..15).doWork
end,
Thread.new do
	users = Users.new('potential', 29, 10..30).doWork
end,
Thread.new do
	users = Users.new('active', 11, 15..50).doWork
end,
Thread.new do
	users = Users.new('veryActive', 9, 15..50).doWork
end
].each{|t| t.join}