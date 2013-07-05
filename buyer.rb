require 'rubygems'
require File.join(File.dirname(__FILE__), 'user.rb')

@@userIndex = 0;
def userId
	sprintf("10%03d%03d", rand(1000), @@userIndex += 1).to_i
end
def sleepFor(from, to)
	sleep(rand(to - from) + from)
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

def count(c)
	rand(c) + 1;
end

begin 
	nonActive = @@nonActive < NonActiveCount ? count(4) : 0;
	nonActive.times do 
		threads << Thread.new do
			User.nonActiveUser(userId()).doWork()
		end 
		sleepFor(5, 15)
	end
	@@nonActive += nonActive
	p "create #{nonActive} nonActive users with total #{@@nonActive}"

	littleActive = @@littleActive < LittleActiveCount ? count(3) : 0;
	littleActive.times do 
		threads << Thread.new do
			User.littleActiveUser(userId()).doWork()
		end 
		sleepFor(5, 15)
	end
	@@littleActive += littleActive
	p "create #{littleActive} littleActive users with total #{@@littleActive}"

	potential = @@potential < PotentialCount ? count(2) : 0;
	potential.times do 
		threads << Thread.new do
			User.potentialUser(userId()).doWork()
		end 
		sleepFor(5, 15)
	end
	@@potential += potential
	p "create #{potential} potential users with total #{@@potential}"

	active = @@active < ActiveCount ? count(1) : 0;
	active.times do 
		threads << Thread.new do
			User.activeUser(userId()).doWork()
		end 
		sleepFor(5, 15)
	end
	@@active += active
	p "create #{active} active users with total #{@@active}"

	veryActive = @@veryActive < VeryActiveCount ? count(1) : 0;
	veryActive.times do 
		threads << Thread.new do
			User.veryActiveUser(userId()).doWork()
		end 
		sleepFor(5, 15)
	end
	@@veryActive += veryActive
	p "create #{veryActive} veryActive users with total #{@@veryActive}"
end while notFinished()

threads.each {|t| t.join}