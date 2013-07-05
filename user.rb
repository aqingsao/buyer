require 'mechanize'
require 'json'

Products=[1,2,3,4,5]
ActionSleepMaxTime=5
class User
	HOST = "http://localhost:3000/"
	def initialize(id, type, actionsCount, productsCount, addToCartRate, addOrderRate, confirmOrderRate, payOrderRate)
		@browser = Mechanize.new
		@id = id
		@type = type
        @orders=Hash.new([])
	end

	def self.nonActiveUser(id)
		new User(id, "nonActiveUser", count(1, 10), count(1, 3), rate(19), rate(10), rate(0), rate(0));
	end
	def self.littleActiveUser(id)
		new User(id, "littleActiveUser", count(20, 100), count(1, 5), rate(20), rate(30), rate(0), rate(0));
	end
	def self.potentialUser(id)
		new User(id, "potentialUser", count(20, 100), count(1, 5), rate(20), rate(50), rate(60), rate(0));
	end
	def self.activeUser(id)
		new User(id, "activeUser", count(50, 200), count(1, 10), rate(20), rate(50), rate(60), rate(80));
	end
	def self.veryActiveUser(id)
		new User(id, "veryActiveUser", count(50, 100), count(1, 10), rate(50), rate(60), rate(80), rate(80));
	end
        
	def doWork
	    actions = genActions()
	    actions.each do |l|
	    	# p "#{@id}: #{@type}: #{l}"
  			# doAction(l[:view], l[:action] || {})
			# sleepFor(5, 10)
	    end
	end

	def login
		get("login", {user: @id})
	end

	def logout
		get("logout", {user: @id})
	end

	def view(productId)
          get("products/#{productId}")
	end

	def compare
	end

	def cart(productId)
	  	p "User #{@id} #{@type} add product #{productId} to cart"
        get("carts/add", {productId: productId})
	end

	def addOrder(productIds)
        orderId = postOrder()
        @orders[orderId] = productIds
	  	p @orders
	end
  	def cancelOrder(o)
	  p "User #{@id} #{@type} cancel order #{o}"
	  get("orders/#{o}/cancel")
 	end
	def confirmOrder(o)
	  p "User #{@id} #{@type} confirm order #{o}"
	  get("orders/#{o}/confirm")
	end
	def viewCart
 	  get 'carts'
	end

	def pay(o)
	  	p "User #{@id} #{@type} pay order #{o}"
       	get("orders/#{o}/pay")
	end	

	private 
	def get(url, parameters={})
		url = sprintf("%s%s?%s", HOST, url, parameters.map{|k, v| "#{k}=#{v}"}.join("&")).chomp('?');
		retryCount = 0;
		begin
			@browser.get(url)
			p "retry to get #{url} successfully after #{retryCount} times" if retryCount > 0
		rescue StandardError => e
			p "Failed to get url #{url}: #{e}"
			sleep(5 * (retryCount += 1))
			retry
		end
	end

	def postOrder
		begin
	        page = viewCart
	        sleepFor(1, 3)
	        form = @browser.page.forms.first
		  	form.submit
	        JSON.parse(@browser.page.content)['order']
	    rescue
	    	p "Failed to postOrder: #{$!} at #{$@}"
	    	0
    	end
	end
	def genActions
	  actions = []
	  actionsCount().times do
	    actions.push randomAction
	  end
	  actions
	end 

    def doAction(viewed, options={})
      	options = {carted: [], addOrder: [], cancelOrder:[], confirmOrder:[], paid:[]}.merge(options)
	    login
	    viewed.each{|p| view(p)}
	     
	    options[:carted].each{|p| cart(p)}
	      
	  	addOrder(options[:addOrder]) unless options[:addOrder].empty?
	  	sleepFor(1, 3)

	    options[:cancelOrder].each{|p| cancelOrder(p)}
	    options[:confirmOrder].each do |p|
			o = @orders.detect{|k,v|v.include?p}.first;
			confirmOrder(o)
	  	end
	  	sleepFor(1, 3)

	    options[:paid].each do |p|
			o = @orders.detect{|k,v|v.include?p}.first;
			pay(o)
	  	end

	  	sleepFor(0, 2)
	  	logout
    end
    
	def randomAction
 		viewedProducts = randomViewedProducts(viewProductCount())   # 
 		addToCart = isAddToCart();
 		cartedProducts = addToCart ? randomCartedProducts(viewedProducts) : [];
 		addOrder = addToCart && isAddOrder();
 		addOrderProducts = addOrder ? [cartedProducts[0]] : [];
 		confirmOrder = addOrder && isConfirmOrder();
 		confirmOrderProducts = confirmOrder ? [cartedProducts[0]] : [];
 		payOrder = confirmOrder && isPayOrder();
 		payProducts = payOrder ? [cartedProducts[0]] : [];

	    {view:viewedProducts, action:{carted:cartedProducts, addOrder:addOrderProducts, confirmOrder:confirmOrderProducts, paid:payProducts}}
	end

    def randomViewedProducts(productCount)
 		productCount.times.each_with_object([]) do |i, products|
 			product = Products[rand(Products.length)]; 
 			products << product unless products.include? product; 
 		end
 	end
	def randomCartedProducts(viewedProducts)
 		(rand(viewedProducts.length) + 1).times.each_with_object([]) do |i, products|
 		 	products<< viewedProducts[i]
 		end
 	end

 	def rate(r)
 		r == 0? false : ( r == 100? true : rand(100) < r) # will return r%
 	end
 	def count(from, to)
 		rand(to - from) + from;
 	end
 	def sleepFor(from, to)
 		sleep(rand(to - from) + from)
 	end
end