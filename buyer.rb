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

def finished
	@@nonActive < NonActiveCount || @@littleActive < LittleActiveCount  || @@potential < PotentialCount  || @@active < ActiveCount || @@veryActive < VeryActiveCount
end

begin 
	nonActive = @@nonActive < NonActiveCount ? (rand(5) + 1) : 0;
	nonActive.times do 
		threads << Thread.new do
			NonActiveUser.new(userId(), 'nonActive').doWork()
			sleepFor(5, 15)
		end 
	end
	@@nonActive += nonActive

	littleActive = @@littleActive < LittleActiveCount ? (rand(5) + 1) : 0;
	littleActive.times do 
		threads << Thread.new do
			LittleActiveUser.new(userId(), 'littleActive').doWork()
			sleepFor(5, 15)
		end 
	end
	@@littleActive += littleActive

	potential = @@potential < PotentialCount ? (rand(5) + 1) : 0;
	potential.times do 
		threads << Thread.new do
			PotentialUser.new(userId(), 'potential').doWork()
			sleepFor(5, 15)
		end 
	end
	@@potential += potential

	active = @@active < ActiveCount ? (rand(5) + 1) : 0;
	active.times do 
		threads << Thread.new do
			ActiveUser.new(userId(), 'active').doWork()
			sleepFor(5, 15)
		end 
	end
	@@active += active

	veryActive = @@veryActive < VeryActiveCount ? (rand(5) + 1) : 0;
	veryActive.times do 
		threads << Thread.new do
			LittleActiveUser.new(userId(), 'veryActive').doWork()
			sleepFor(5, 15)
		end 
	end
	@@veryActive += veryActive
end while !finished()

threads.each {|t| t.join}