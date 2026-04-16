require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
require "sinatra/json"
require 'sinatra/cross_origin'
require 'json'

configure do
 enable :cross_origin
end

set :sessions, #fixa att den sparar sessions så att den kan kommunicera med svelte och tillbaka
  key: 'session',
  httponly: true,
  same_site: :none, #viktigt för kommunikationen
  secure: false   #för lokalt

# Handle preflight OPTIONS requests automatically AI GENERERAT FÖR ATT HJÄLPA ATT SINATRA ALLTID TAR EMOT REQUESTS FRÅN SVELTE
options "*" do
  response.headers['Access-Control-Allow-Origin'] = 'http://localhost:5173'
  response.headers['Access-Control-Allow-Credentials'] = 'true'
  response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Content-Type"
  200
end
before do
  response.headers['Access-Control-Allow-Origin'] = 'http://localhost:5173'
  response.headers['Access-Control-Allow-Credentials'] = 'true'
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
end

#ersätts av set :sessions enable :sessions
set :session_secret, "3UIUWFIWEIGGUIg#giug#uigIFGIWEFIUFUWEGFWJKNFJWJKEHKFUFHWHFKHEUIHSSFF"

#rekommenderad för bättre security
def require_admin!
  halt 403, "ONLY TOP TIER ACCESS" unless session[:role] == 'admin'
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

#ADMIN
get("/admin/users") do
  require_admin!
  db = db_connection
  json db.execute("SELECT id, username, email, role FROM users")
end
#categories
post("/admin/categories") do
  require_admin!
  db = db_connection
  data = JSON

  db.execute("INSERT INTO categories(name) VALUES (?), data["name"]")
  json([success: true])
end
delete("/admin/categories/:id") do
  db = db_connection
  db.execute("DELETE FROM categories WHERE id = ?" params[:id].to_i)
  json([success: true])
end

#TESTING DATABASE
#USERS
#checker om logged in och skickas som data till Svelte som läser av logged_in true or false
get("/api/user") do
  if session[:user_id]
    json({ logged_in: true, user_id: session[:user_id], role: session[:role]})
  else
    json({logged_in: false})
  end
end

#SIGN-IN
post("/api/signup") do
  db = db_connection
  data = JSON.parse(request.body.read)
  username = data["username"]
  email = data["email"]
  password = data["password"]

  password = BCrypt::Password.create(password)

  db.execute("INSERT INTO users(username, email, pwd_digest, role) VALUES (?, ?, ? ,?)", username, email, password, "user")
end

#LOGIN
post("/api/login") do
  #JSON parse logik information från AI
  db = db_connection
  data = JSON.parse(request.body.read)
  email = data["email"]
  password = data["password"]
  user = db.execute("SELECT * FROM users WHERE email=?", email).first

  if user && BCrypt::Password.new(user['pwd_digest']) == password
    session[:user_id] = user['id']
    session[:role] = user['role']
    json({success: true, message: "Login successful", role: user['role']})


  else

    json({success: false, message: "Invalid email or password"})
  end


end

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
get("/api/creators/:creator_id/products") do
  db = db_connection
  creator_id = params[:creator_id].to_i

  products = db.execute("SELECT * FROM products WHERE creator_id = ?", creator_id)
  json products
end

get("/api/creators/:creator_id/products/:id") do
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
get("/api/creators/:creator_id/products/:product_id/reviews") do
  db = db_connection
  product_id = params[:product_id].to_i
  reviews = db.execute("SELECT * FROM reviews WHERE product_id = ?", product_id)
  json reviews
end

post("/api/creators/:creator_id/products/:product_id/reviews") do
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

#edit
get("/api/creators/:creator_id/products/:product_id/reviews/:id") do
  db = db_connection
  id = params[:id].to_i
  review = db.execute("SELECT * FROM reviews WHERE id = ? AND product_id = ?", id).first
  json review
end

#update
put("/api/creators/:creator_id/products/:product_id/reviews/:id") do
  db = db_connection
  product_id = params[:product_id].to_i
  review_id = params[:id].to_i

  request_payload = JSON.parse(request.body.read)
  rating = request_payload["rating"].to_i
  comment = request_payload["comment"]

  db.execute("UPDATE reviews SET rating = ?, comment = ? WHERE id = ? AND product_id = ?", rating, comment, review_id, product_id)
  updated_review = db.execute("SELECT * FROM reviews WHERE id = ? AND product_id = ?", review_id, product_id).first

  json updated_review
end

#delete
delete("/api/creators/:creator_id/products/:product_id/reviews/:id") do
  db = db_connection
  review_id = params[:id].to_i
  db.execute("DELETE FROM reviews WHERE id = ? AND product_id = ?", review_id)
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




