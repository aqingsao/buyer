require 'mechanize'
require 'json'

GuestActions=5
Products=[1,2,3,4,5]
ActionSleepMaxTime=5
class User
	HOST = "http://localhost:3000/"
	def initialize(id)
		@browser = Mechanize.new
		@id = id
        @orders=Hash.new([])
	end
        
	def doWork
	    actions = genActions()
	    actions.each do |l|
	    	p "#{@id}: #{l}"
  			# shopping(l[:view], l[:action] || {})
			# sleep(Random.rand(ActionSleepMaxTime))
	    end
	end
	def genActions
	  actions = []
	  actionsCount().times do
	    actions.push randomAction
	  end
	  p "Generate #{actions.length} actions for user #{@id}"
	  actions
	end 
    def shopping(viewed, options={})
      	options = {carted: [], addOrder: [], cancelOrder:[], confirmOrder:[], paid:[]}.merge(options)
	    login
	    viewed.each{|p| view(p)}
	     
	    options[:carted].each{|p| cart(p)}
	      
	  	addOrder(options[:addOrder]) unless options[:addOrder].empty?

	    options[:cancelOrder].each{|p| cancelOrder(p)}
	    options[:confirmOrder].each do |p|
			o = @orders.detect{|k,v|v.include?p}.first;
			confirmOrder(o)
	  	end
	    options[:paid].each do |p|
			o = @orders.detect{|k,v|v.include?p}.first;
			pay(o)
	  	end
	  	logout
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
	  p "user #{@id} add product #{productId} to cart"
          get("carts/add", {productId: productId})
	end

	def addOrder(productIds)
          orderId = postOrder("orders", {"productIds[]"=>1})
          @orders[orderId] = productIds
	  p @orders
	end
  	def cancelOrder(o)
	  p "cancel order #{o}"
	  get("orders/#{o}/cancel")
 	end
	def confirmOrder(o)
	  p "confirm order #{o}"
	  get("orders/#{o}/confirm")
	end
	def viewCart
 	  get 'carts'
	end

	def pay(o)
	  p "pay order #{o}"
          get("orders/#{o}/pay")
	end	
    
    def randomProducts(maxCount)
 		p = []; 
 		(rand(maxCount)+1).times{p.push Products[rand(5)]}; 
 		p.uniq
 	end
    

	private 
	def get(url, parameters={})
		url = HOST+url
		url += ("?" + parameters.map{|k, v| "#{k}=#{v}"}.join("&")) unless parameters.empty?
		@browser.get(url)
	end

	def postOrder(url, data)
          page = viewCart
          form = @browser.page.forms.first
	  form.submit
          JSON.parse(@browser.page.content)['order']
	end
end
class NonActiveUser < User # ~100
	def actionsCount
		rand(2) + 1  # 1-2 actions
	end
 	def randomAction
 		viewedProducts = randomProducts(3) # view 1-3 products
  		{view:viewedProducts, action:{carted:[]}}
 	end
 	def randomCarted(viewedProducts)
 		return rand(3) == 0 ? [viewedProducts[0]] : [] # 1/3 will add product to cart
 	end
end
class PotentialUser < User # ~20 
	def actionsCount
		rand(5) + 1   # 1-5 actions
	end
 	def randomAction
 		viewedProducts = randomProducts(10)   # 1-10 products
 		cartedProducts = rand(3) == 0 ? [viewedProducts[0]] : []; # 1/3 will cart 
 		addOrder = !cartedProducts.empty? && rand(2) > 0;  # 1/2 will add order
 		addOrderProducts = addOrder ? [cartedProducts[0]] : []; 
 		confirmOrder = addOrder && rand(2) > 0; # 1/2 will confirm order
 		confirmOrderProducts = confirmOrder ? [cartedProducts[0]] : [];
  		{view:viewedProducts, action:{carted: cartedProducts, addOrder: addOrderProducts, confirmOrder:confirmOrderProducts}}
 	end
end

class ActiveUser < User 	#~ 10
	def actionsCount
		rand(5) + 1
	end

	def randomAction
 		viewedProducts = randomProducts(10)
 		cartedProducts = randomCarted(viewedProducts);
 		addOrder = !cartedProducts.empty? && rand(8) > 0;
 		addOrderProducts = addOrder ? [cartedProducts[0]] : [];
 		confirmOrder = addOrder && rand(8) > 0;
 		confirmOrderProducts = confirmOrder ? [cartedProducts[0]] : [];
 		payOrder = confirmOrder && rand(8) > 0;
 		payProducts = payOrder ? [cartedProducts[0]] : [];

	    {view:viewedProducts, action:{carted:cartedProducts, addOrder:addOrderProducts, confirmOrder:confirmOrderProducts, paid:payProducts}}
	end
	def randomCarted(viewedProducts)
		cartedProducts = []
 		rand(viewedProducts.length).times do 
 		 	cartedProducts<< viewedProducts[rand(viewedProducts.length)]
 		end
 		cartedProducts << viewedProducts[0] if rand(1) == 0 && cartedProducts.empty?
 		cartedProducts.uniq
 	end
end
class VerifyActiveUser < User 	# ~5
	def actionsCount
		rand(10) + 5
	end

	def randomAction
 		viewedProducts = randomProducts(10)
 		cartedProducts = randomCarted(viewedProducts);
 		addOrder = !cartedProducts.empty? && rand(8) > 0;
 		addOrderProducts = addOrder ? [cartedProducts[0]] : [];
 		confirmOrder = addOrder && rand(8) > 0;
 		confirmOrderProducts = confirmOrder ? [cartedProducts[0]] : [];
 		payOrder = confirmOrder && rand(8) > 0;
 		payProducts = payOrder ? [cartedProducts[0]] : [];

	    {view:viewedProducts, action:{carted:cartedProducts, addOrder:addOrderProducts, confirmOrder:confirmOrderProducts, paid:payProducts}}
	end
	def randomCarted(viewedProducts)
		cartedProducts = []
 		rand(viewedProducts.length).times do 
 		 	cartedProducts<< viewedProducts[rand(viewedProducts.length)]
 		end
 		cartedProducts << viewedProducts[0] if rand(1) == 0 && cartedProducts.empty?
 		cartedProducts.uniq
 	end
end
