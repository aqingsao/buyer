require 'mechanize'
require 'json'
require File.join(File.dirname(__FILE__), 'util.rb')
require File.join(File.dirname(__FILE__), 'product.rb')

class Product
	attr_reader :id, :name, :price
	def initialize(id, name, price)
		@id = id
		@name = name
		@price = price
	end
end
class Admin
	include Util
	@@productIndex = 0;
	HOST = "http://localhost:3000/"

	def initialize
		@browser = Mechanize.new
		@products = []
	end
	def createProducts(count)
		count.times.each_with_object([]) do |i, products|
			product = Product.new(productId, "Product #{i}", rand(10000).to_f)
			products << product if createProduct(product)
		end
	end
	def updateProducts(products, rate)
		products.each do |p|
			updateProduct(p, rate)
		end
	end
	private
 	def productId
		sprintf("34%03d%02d", rand(1000), @@productIndex += 1).to_i
	end
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

	def createProduct(product)
		begin
			newProductPage = get("products/new")
	        form = @browser.page.forms.first
			form['product[id]']=product.id
			form['product[name]']=product.name
			form['product[price]']=product.price
	        sleepFor(2, 4)
		  	form.submit
		  	p "Create product(#{product.id}) #{product.name} with price #{product.price}"
		  	true
	    rescue
	    	p "Failed to create product: #{$!} at #{$@}"
	    	false
    	end
	end

	def updateProduct(productId, rate)
		begin
			editPage = get("products/#{productId}/edit")
	        form = @browser.page.forms.first
	        currentPrice = form['product[price]'];
	        newPrice = (currentPrice.to_f * rate).round(2)
			form['product[price]'] = newPrice
		  	form.submit
		  	p "Update price of product(#{productId}) from #{currentPrice} to #{newPrice}"
	        sleepFor(2, 4)
		  	true
		rescue
		end
	end
end

admin = Admin.new
# admin.createProducts(2)
admin.updateProducts(Products, 0.7)