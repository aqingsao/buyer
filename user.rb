require 'mechanize'
require 'json'

class User
	HOST = "http://localhost:3000/"
	def initialize(id)
		@browser = Mechanize.new
		@id = id
                @orders=Hash.new([])
	end
        
	def doWork
	    actions = genActions()
	    actions.each{|l| shopping(l[:view], l[:action]|| {}); sleep(Random.rand(30))}
	end
	def genActions
	  []
	end
        def shopping(viewed, options={})
          options = {carted: [], addOrder: [], cancelOrder:[], confirmOrder:[], paid:[]}.merge(options)
          login
          viewed.each{|p| view(p)}
         
          options[:carted].each{|p| cart(p)}
          
	  addOrder(options[:addOrder]) unless options[:addOrder].empty?

          options[:cancelOrder].each{|p| cancelOrder(p)}
          options[:confirmOrder].each{|p|
		o = @orders.detect{|k,v|v.include?p}.first;
		confirmOrder(o)
	  }
          options[:paid].each{|p|
		o = @orders.detect{|k,v|v.include?p}.first;
		pay(o)
	  }
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
	  p "Add product #{productId} to cart"
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
class GuestUser < User
 def genActions
  [{view:[1], action:{carted:[1]}}]
 end 
end
class ActiveUser < User
  def genActions
    [{view:[1, 2], action:{carted:[1]}}]
  end
end
