require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
require "sinatra/json"
require 'sinatra/cross_origin'

configure do
 enable :cross_origin
end
before do
 response.headers['Access-Control-Allow-Origin'] = '*'
end

#Easier to connect databases
def db_connection
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  db
end

# API-endpoint
get("/api/data") do
 json({message: "Hello from Sinatra", timestamp: Time.now})
end

#TESTING DATABASE

#CREATORS
get("/api/creators") do
  db = db_connection
  creators = db.execute("SELECT * FROM creators")
  json creators
end

get("/api/creators/:id") do
  db = db_connection
  id = params[:id].to_i

  creator = db.execute("SELECT * FROM creators WHERE id = ?", id).first
  socials = db.execute("SELECT * FROM social_medias WHERE creator_id = ?", id)
  merch = db.execute("SELECT * FROM products WHERE creator_id = ?", id)


  json({ creator: creator,socials: socials, merch: merch  })
end

#PRODUCTS
get("/api/products") do
  db = db_connection
  products = db.execute("SELECT * FROM products")
  json products
end

get("/api/products/:id") do
  db = db_connection
  id = params[:id].to_i
  product = db.execute("SELECT * FROM products WHERE id = ?", id).first
  options = db.execute("SELECT option_types.name AS option_type, option_values.value, option_values.price_modifier FROM product_option_types 
  JOIN option_types ON product_option_types.option_type_id = option_types.id
  JOIN option_values ON option_values.option_type_id = option_types.id
  WHERE product_option_types.product_id = ?", id)

  json({product: product, options: options })

end

#ORDERS
get("/api/orders") do
  db = db_connection
  id = params[:id].to_i
  orders = db.execute("SELECT * FROM orders")
  json orders
end


#REVIEWS
get("/api/products/product:id/reviews") do
  db = db_connection
  product_id = params[:product_id].to_i
  reviews = db.execute("SELECT * FROM reviews WHERE product_id = ?", product_id)
  json reviews
end

post("/api/products/:product_id/reviews") do
  db = db_connection
  product_id = params[:product_id].to_i

  #Parse JSON sent from user from Svelte
  request_payload = JSON.parse(request.body.read)
  user_id = request_payload["user_id"].to_i
  rating = request_payload["rating"].to_i
  comment = request_payload["comment"]

  db.execute("INSERT INTO reviews (user_id, product_id, rating, comment, created_at) VALUES(?, ?, ?, ?, ?)",
  user_id, product_id, rating, comment, Time.now.to_s)

  new_review = db.execute("SELECT * FROM  reviews WHERE rowid = last_insert_rowid()").first
  json new_review
end

get("/api/products/:product_id/reviews/:id/edit") do
  db = db_connection
  product_id = params[:product_id].to_i
  id = params[:id].to_i
  review = db.execute("SELECT * FROM reviews WHERE id = ?", id).first
  json review
end

post("/api/products/:product_id/reviews/:id/delete") do
  db = db_connection
  review_id = params[:id].to_i
  db.execute("DELETE FROM reviews WHERE id = ?", review_id)
  json review_id
end



#VOTES
get("/api/votes/:creator_id") do
  db = db_connection
  creator_id = params[:creator_id].to_i
  votes = db.execute("SELECT * FROM votes WHERE creator_id = ?", creator_id)
  json votes
end

#HOME
get('/') do
  db = db_connection
  creators = db.execute("SELECT name FROM creators")
  json creators
end




