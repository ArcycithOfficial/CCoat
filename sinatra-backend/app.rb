require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
require "sinatra/json"
require 'sinatra/cross_origin'
require 'json'
require 'securerandom'

Dir[File.join(__dir__, 'models', '*.rb')].each { |f| require_relative f }

configure do
  enable :cross_origin
end

set :protection, except: :http_origin

def csrf_token
  session[:csrf] ||= SecureRandom.hex(32)
end

def require_admin!
  halt 403, { error: "ONLY TOP TIER ACCESS" }.to_json unless session[:role] == 'admin'
end

def require_login!
  halt 401, { error: "Must be logged in" }.to_json unless session[:user_id]
end

set :sessions, {
  key: 'session',
  httponly: true,
  same_site: :lax,
}

options "*" do
  response.headers['Access-Control-Allow-Origin'] = 'http://localhost:5173'
  response.headers['Access-Control-Allow-Credentials'] = 'true'
  response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = 'Content-Type, X-CSRF-Token'
  halt 200
end

before do
  response.headers['Access-Control-Allow-Origin'] = 'http://localhost:5173'
  response.headers['Access-Control-Allow-Credentials'] = 'true'
  response.headers["Access-Control-Allow-Headers"] = 'Content-Type, X-CSRF-Token'
end

before "/admin/*" do
  pass if request.request_method == "OPTIONS"
  require_admin!
  token = request.env["HTTP_X_CSRF_TOKEN"]
  halt 403, { error: "CSRF token missing or invalid" }.to_json unless token && token == session[:csrf]
end

set :session_secret, "3UIUWFIWEIGGUIg#giug#uigIFGIWEFIUFUWEGFWJKNFJWJKEHKFUFHWHFKHEUIHSSFF"

def db_connection
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  db.execute("PRAGMA foreign_keys = ON")
  db
end

# CSRF
get("/api/csrf") do
  json csrf: csrf_token
end

# USER
get("/api/user") do
  if session[:user_id]
    json({ logged_in: true, user_id: session[:user_id], role: session[:role] })
  else
    json({ logged_in: false })
  end
end

# AUTH
post("/api/signup") do
  db = db_connection
  data = JSON.parse(request.body.read)
  digest = BCrypt::Password.create(data["password"])
  User.create(db, data["username"], data["email"], digest)
end

post("/api/login") do
  db = db_connection
  data = JSON.parse(request.body.read)
  email = data["email"]
  ip = request.ip

    # hjälp kod från AI för att kunna räkna och lägga timear för login attempts
  recent_fails = db.execute("SELECT COUNT(*) as count FROM login_attempts 
    WHERE ip = ? AND success = 0 AND created_at > datetime('now', '-2 minutes')",
    ip).first["count"]

  if recent_fails >= 5
    db.execute("INSERT INTO login_attempts (email, ip, success) VALUES (?, ?, ?)", [email, ip, 0])
    halt 429, json({ success: false, message: "Too many failed attempts. Try again in 2 minutes." })
  end

  user = User.find_by_email(db, email)


  if user && BCrypt::Password.new(user['pwd_digest']) == data["password"]
    session.clear
    session[:user_id] = user['id']
    session[:role] = user['role']
    session[:csrf] = SecureRandom.hex(32)
    json({ success: true, message: "Login successful", role: user['role'] })
  else
    db.execute("INSERT INTO login_attempts (email, ip, success) VALUES (?, ?, ?)", [email, ip, 0])
    puts "[LOGIN] FAILED — #{email} from #{ip} at #{Time.now}"
    json({ success: false, message: "Invalid email or password" })
  end
end

post("/api/logout") do
  session.clear
  json success: true
end

# CATEGORIES
get("/api/categories") do
  json Category.all(db_connection)
end

post("/admin/categories") do
  data = JSON.parse(request.body.read)
  id = Category.create(db_connection, data["name"])
  json({ success: true, id: id, name: data["name"] })
end

put("/admin/categories/:id") do
  data = JSON.parse(request.body.read)
  Category.update(db_connection, params[:id].to_i, data["name"])
  json({ success: true })
end

delete("/admin/categories/:id") do
  Category.delete(db_connection, params[:id].to_i)
  json({ success: true })
end

# PRODUCTS ADMIN
get("/admin/products") do
  json Product.all(db_connection)
end

post("/admin/creators/:creator_id/products") do
  db = db_connection
  data = JSON.parse(request.body.read)
  id = Product.create(db, params[:creator_id].to_i, data)
  json({ success: true, id: id })
end

put("/admin/products/:id") do
  db = db_connection
  data = JSON.parse(request.body.read)
  Product.update(db, params[:id].to_i, data)
  json({ success: true })
end

delete("/admin/products/:id") do
  Product.delete(db_connection, params[:id].to_i)
  json({ success: true })
end

# PRODUCT OPTIONS
post("/admin/products/:id/options") do
  db = db_connection
  data = JSON.parse(request.body.read)
  Product.add_option(db, params[:id].to_i, data["option_type_id"].to_i)
  json({ success: true })
end

delete("/admin/products/:id/options/:option_type_id") do
  Product.remove_option(db_connection, params[:id].to_i, params[:option_type_id].to_i)
  json({ success: true })
end

# CREATORS
get("/api/creators") do
  json Creator.all(db_connection)
end

get("/api/creators/:id") do
  db = db_connection
  id = params[:id].to_i
  creator = Creator.find(db, id)
  socials = Social.for_creator(db, id)
  merch = Product.for_creator(db, id)
  categories = Creator.categories(db, id)
  json({ creator: creator, socials: socials, merch: merch, categories: categories })
end

post("/admin/creators") do
  data = JSON.parse(request.body.read)
  id = Creator.create(db_connection, data)
  json({ success: true, creator: data.merge({ "id" => id }) })
end

put("/admin/creators/:id") do
  data = JSON.parse(request.body.read)
  Creator.update(db_connection, params[:id].to_i, data)
  json({ success: true, creator: data.merge({ "id" => params[:id].to_i }) })
end

delete("/admin/creators/:id") do
  Creator.delete(db_connection, params[:id].to_i)
  json({ success: true })
end

post("/admin/creators/:id/categories") do
  data = JSON.parse(request.body.read)
  Creator.add_category(db_connection, params[:id].to_i, data["category_id"].to_i)
  json({ success: true })
end

delete("/admin/creators/:id/categories/:category_id") do
  Creator.remove_category(db_connection, params[:id].to_i, params[:category_id].to_i)
  json({ success: true })
end

# REVIEWS
get("/api/creators/:creator_id/products/:product_id/reviews") do
  json Review.for_product(db_connection, params[:product_id].to_i)
end

post("/api/creators/:creator_id/products/:product_id/reviews") do
  require_login!
  db = db_connection
  data = JSON.parse(request.body.read)
  id = Review.create(db, data["user_id"].to_i, params[:product_id].to_i, data["rating"].to_i, data["comment"])
  review = Review.find(db, id)
  json({ success: true, review: review })
end

put("/api/creators/:creator_id/products/:product_id/reviews/:id") do
  require_login!
  db = db_connection
  data = JSON.parse(request.body.read)
  review = Review.update(db, params[:id].to_i, params[:product_id].to_i, data["rating"].to_i, data["comment"])
  json review
end

delete("/api/creators/:creator_id/products/:product_id/reviews/:id") do
  require_login!
  Review.delete(db_connection, params[:id].to_i, params[:product_id].to_i)
  json({ success: true })
end

# ADMIN
get("/admin/users") do
  json User.all(db_connection)
end

# PRODUCTS
get("/api/creators/:creator_id/products") do
  json Product.for_creator(db_connection, params[:creator_id].to_i)
end

get("/api/creators/:creator_id/products/:id") do
  db = db_connection
  product = Product.find(db, params[:id].to_i)
  options = Product.options(db, params[:id].to_i)
  json({ product: product, options: options })
end

# OPTION TYPES
get("/api/option_types") do
  json OptionType.all(db_connection)
end

post("/admin/option_types") do
  data = JSON.parse(request.body.read)
  id = OptionType.create(db_connection, data["name"])
  json({ success: true, id: id, name: data["name"] })
end

delete("/admin/option_types/:id") do
  OptionType.delete(db_connection, params[:id].to_i)
  json({ success: true })
end

# OPTION VALUES
get("/api/option_types/:id/values") do
  json OptionValue.for_type(db_connection, params[:id].to_i)
end

post("/admin/option_types/:id/values") do
  data = JSON.parse(request.body.read)
  id = OptionValue.create(db_connection, params[:id].to_i, data["value"], data["price_modifier"].to_i)
  json({ success: true, id: id })
end

put("/admin/option_values/:id") do
  data = JSON.parse(request.body.read)
  OptionValue.update(db_connection, params[:id].to_i, data["value"], data["price_modifier"].to_i)
  json({ success: true })
end

delete("/admin/option_values/:id") do
  OptionValue.delete(db_connection, params[:id].to_i)
  json({ success: true })
end

# PRODUCT OPTION VALUES
get("/api/products/:id/option_values") do
  json Product.option_values(db_connection, params[:id].to_i)
end

post("/admin/products/:id/option_values") do
  data = JSON.parse(request.body.read)
  Product.add_option_value(db_connection, params[:id].to_i, data["option_value_id"].to_i)
  json({ success: true })
end

delete("/admin/products/:id/option_values/:option_value_id") do
  Product.remove_option_value(db_connection, params[:id].to_i, params[:option_value_id].to_i)
  json({ success: true })
end