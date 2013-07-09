def findProducts
	browser = Mechanize.new
	browser.get("http://localhost:3000/products/ids")
	JSON.parse(browser.page.content)
end
Products = findProducts
p "There are #{Products.length} products: #{Products}"
