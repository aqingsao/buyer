class User
	HOST = "http://localhost:3000/"
	def initialize(id)
		@browser = Mechanize.new
		@id = id
	end

	def login
		get("login", {user, @id})
	end

	def view
	end

	def compare
	end

	def addToCart
	end

	def order
	end

	def pay
	end	

	private 
	def get(url, parameters)
		@browser.get(HOST + url)
	end

	def post
	end
end