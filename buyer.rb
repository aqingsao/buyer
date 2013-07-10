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
				userId = userId()
				User.method(@type).call(userId).doWork()
				p "create user #{userId} with total #{@threads.length}  #{@type} users"
			end
		end while @threads.length < @count
		@threads.each{|t| t.join}
	end

	private
	def userId
		sprintf("10%03d%03d", rand(1000), @@userIndex += 1).to_i
	end
end

# for subject 1
users = [{type: 'nonActive', count: 200, interval: 4..10}, 
	{type: 'littleActive', count: 51, interval: 10..20}, 
	{type: 'potential', count: 29, interval: 20..50}, 
	{type: 'active', count: 11, interval: 50..100},
	{type: 'veryActive', count: 9, interval: 50..100}, 
]
# for subject 2
users = [{type: 'nonActive', count: 200, interval: 4..10}, 
	{type: 'littleActive', count: 51, interval: 10..20}, 
	{type: 'potential', count: 29, interval: 20..50}, 
	{type: 'active', count: 11, interval: 50..100},
	{type: 'veryActive', count: 9, interval: 50..100}, 
	{type: 'valued', count: 9, interval: 50..100}
]
# for subject 3
users = [{type: 'nonActive', count: 200, interval: 4..10}, 
	{type: 'littleActive', count: 51, interval: 10..20}, 
	{type: 'potential', count: 29, interval: 20..50}, 
	{type: 'activeLow', count: 11, interval: 50..100},
	{type: 'activeMiddle', count: 9, interval: 50..100}, 
	{type: 'activeHigh', count: 10, interval: 50..100}, 
	{type: 'veryActiveLow', count: 8, interval: 50..100},
	{type: 'veryActiveMiddle', count: 7, interval: 50..100}, 
	{type: 'veryActiveHigh', count: 5, interval: 50..100}, 
]

users.collect do |l|
	Thread.new do
		Users.new(l[:type], l[:count], l[:interval]).doWork
	end
end.each{|t| t.join}
