require 'mechanize'

class User
	HOST = "http://localhost:3000/"
	def initialize(id)
		@browser = Mechanize.new
		@id = id
	end

	def login
		get("login", {user: @id})
	end

	def logout
		get("logout", {user: @id})
	end

	def view(productId)
          get("products", {productId: productId})
	end

	def compare
	end

	def cart(productId)
          get("carts/add", {productId: productId})
	end

	def order
          
	end

	def pay
	end	
        
        def shopping(viewed, compared=[], carted=[], ordered=[], paid=[])
          login
          viewed.each{|p| view(p)}
          carted.each{|p| cart(p)}
          ordered.each{|p| order(p)}
        end

	private 
	def get(url, parameters={})
		url = HOST+url
		url += ("?" + parameters.map{|k, v| "#{k}=#{v}"}.join("&")) unless parameters.empty?
		@browser.get(url)
	end

	def post
	end
end
