require 'mechanize'
require 'json'
require File.join(File.dirname(__FILE__), 'util.rb')
require File.join(File.dirname(__FILE__), 'product.rb')

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

	def self.nonActive(id)
		User.new(id, "nonActiveUser", count(1, 10), 1..3, 19, 10, 0, 0);
	end
	def self.littleActive(id)
		User.new(id, "littleActiveUser", count(20, 100), 1..5, 20, 30, 0, 0);
	end
	def self.potential(id)
		User.new(id, "potentialUser", count(20, 100), 1..5, 20, 50, 60, 0);
	end
	def self.active(id)
		User.new(id, "activeUser", count(50, 200), 1..10, 20,100, 60, 80);
	end
	def self.veryActive(id)
		User.new(id, "veryActiveUser", count(50, 100), 1..10, 50, 60, 80, 80);
	end
        
	def doWork
		  @actionsCount.times() do |i|
		    action = randomAction
	    	# p "#{@id}: #{@type}: #{action}"
  			doAction(action[:view], action[:action] || {})
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
	def clearCart
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
	def delete(url)
		@browser.delete("#{HOST}#{url}")
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

    def doAction(viewed, options={})
      	options = {carted: [], addOrder: [], cancelOrder:[], confirmOrder:[], paid:[]}.merge(options)
	    login
	  	sleepFor(1, 5)
	    viewed.each{|p| sleepFor(2, 5); view(p)}
	     
	  	sleepFor(3, 10)
	    options[:carted].each{|p| sleepFor(2, 5); cart(p)}
	      
	  	sleepFor(3, 10)
	  	addOrder(options[:addOrder]) unless options[:addOrder].empty?
	  	sleepFor(1, 5)

	    options[:cancelOrder].each{|p| cancelOrder(p)}
	    options[:confirmOrder].each do |p|
			o = @orders.detect{|k,v|v.include?p}.first;
			confirmOrder(o)
	  	end
	  	sleepFor(1, 5)

	    options[:paid].each do |p|
			o = @orders.detect{|k,v|v.include?p}.first;
			pay(o)
	  	end

	  	sleepFor(3, 6)
	  	delete("carts/removeAll")
	  	logout
	  	sleepFor(1, 5)
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
    def randomViewedProducts(productCount)
 		productCount.times.each_with_object([]) do |i, products|
 			product = Products[rand(Products.length)]; 
 			products << product unless products.include? product; 
 		end
 	end
 	def selectProduct

 	end
	def randomCartedProducts(viewedProducts)
 		(rand(viewedProducts.length) + 1).times.each_with_object([]) do |i, products|
 		 	products<< viewedProducts[i]
 		end
 	end
end