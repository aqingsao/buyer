module Util
	 def rate(r)
 		r == 0? false : ( r == 100? true : rand(100) < r) # will return r%
 	end
 	def count(from, to)
 		from == to ? from: (rand(to - from) + from)
 	end
 	def sleepFor(from, to)
 		sleep(rand(to - from) + from)
 	end

 	def price(from, to)
 		from == to ? from.to_f: (rand(to - from + 1) + from).to_f
 	end
end