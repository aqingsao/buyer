require 'mechanize'
require 'json'
require File.join(File.dirname(__FILE__), 'util.rb')

Products=[1,2,3,4,5]
ActionSleepMaxTime=5
class User
	include Util

	HOST = "http://localhost:3000/"
	def initialize(id, type, actionsCount, viewedProductsRange, addToCartRate, addOrderRate, confirmOrderRate, payOrderRate)
		@browser = Mechanize.new
		@id = id
		@type = type
        @orders=Hash.new([])
        @actionsCount = actionsCount
        @viewedProductsRange = viewedProductsRange
        @addToCartRate = addToCartRate
        @addOrderRate = addOrderRate
        @confirmOrderRate = confirmOrderRate
        @payOrderRate = payOrderRate
	end

	def self.nonActiveUser(id)
		User.new(id, "nonActiveUser", count(1, 10), 1..3, 19, 10, 0, 0);
	end
	def self.littleActiveUser(id)
		User.new(id, "littleActiveUser", count(20, 100), 1..5, 20, 30, 0, 0);
	end
	def self.potentialUser(id)
		User.new(id, "potentialUser", count(20, 100), 1..5, 20, 50, 60, 0);
	end
	def self.activeUser(id)
		User.new(id, "activeUser", count(50, 200), 1..10, 20,100, 60, 80);
	end
	def self.veryActiveUser(id)
		User.new(id, "veryActiveUser", count(50, 100), 1..10, 50, 60, 80, 80);
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
	  @actionsCount.times.each_with_object([]) do |i, actions|
	    actions << randomAction
	  end
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
 		viewedProducts = randomViewedProducts(count(@viewedProductsRange.first, @viewedProductsRange.last))
 		addToCart = rate(@addToCartRate);
 		cartedProducts = addToCart ? randomCartedProducts(viewedProducts) : [];
 		addOrder = addToCart && rate(@addOrderRate);
 		addOrderProducts = addOrder ? [cartedProducts[0]] : [];
 		confirmOrder = addOrder && rate(@confirmOrderRate);
 		confirmOrderProducts = confirmOrder ? [cartedProducts[0]] : [];
 		payOrder = confirmOrder && rate(@payOrderRate);
 		payProducts = payOrder ? [cartedProducts[0]] : [];

	    {view:viewedProducts, action:{carted:cartedProducts, addOrder:addOrderProducts, confirmOrder:confirmOrderProducts, paid:payProducts}}
	end
	def isAddToCart
		rate(@addToCartRate);
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
end