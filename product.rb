require 'mechanize'
require 'json'

def findProducts
	browser = Mechanize.new
	browser.get("http://localhost:3000/products/all")
	JSON.parse(browser.page.content)
end
Products = findProducts