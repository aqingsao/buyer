require 'rubygems'
require File.join(File.dirname(__FILE__), 'user.rb')
require File.join(File.dirname(__FILE__), 'util.rb')
include Util

class Users
	@@userIndex = 0;
	attr_reader :threads

	def initialize(type, count, interval)
		@type = type
		@count = count
		@interval = interval
		@threads = []
	end

	def doWork
		begin
			sleepFor(@interval.first, @interval.last)
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

[{type: 'nonActive', count: 200, interval: 1..5}, 
	{type: 'littleActive', count: 51, interval: 5..15}, 
	{type: 'potential', count: 29, interval: 10..30}, 
	{type: 'active', count: 11, interval: 15..50}, 
	{type: 'veryActive', count: 9, interval: 15..50}, 
].collect do |l|
	p l
	Thread.new do
		Users.new(l[:type], l[:count], l[:interval]).doWork
	end
end.each{|t| t.join}