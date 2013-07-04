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
          get(sprintf("products/%d", productId))
	end

	def compare
	end

	def addToCart
	end

	def order
	end

	def pay
	end	
        
        def shopping(viewed, compared=[], added=[], bought=[], paid=[])
          login
          viewed.each{|p| view(p)}
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