require 'sqlite3'

db = SQLite3::Database.new("database.db")


def seed!(db)
  puts "Using db file: db/database.db"
  puts "🧹 Dropping old tables..."
  drop_tables(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"
end

def drop_tables(db)
  db.execute('DROP TABLE IF EXISTS creators')
  db.execute('DROP TABLE IF EXISTS merch')
  db.execute('DROP TABLE IF EXISTS social_medias')
  db.execute('DROP TABLE IF EXISTS users')
  db.execute('DROP TABLE IF EXISTS categories')
end

def create_tables(db)
  #users
  db.execute('CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL, 
              email TEXT NOT NULL,
              pwd_digest TEXT NOT NULL,
              created_at TEXT,
              profile_picture
              )')
  #creators
  db.execute('CREATE TABLE creators (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              username TEXT NOT NULL,
              real_name TEXT, 
              nationality TEXT, 
              age integer,
              about_me TEXT,
              profile_image TEXT,
              banner_image TEXT,
              created_at TEXT,
              theme_color TEXT
              )')    
  #categories
  db.execute('CREATE TABLE categories (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL
              )') 
  #Social_medias
  db.execute('CREATE TABLE social_medias (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              creator_id INTEGER,
              platform TEXT,
              username TEXT,
              followers INTEGER,
              views INTEGER,
              )')               
  #Creator_Categories (many to many)
  db.execute('CREATE TABLE creator_categories(
              creator_id INTEGER,
              category_id INTEGER,
              PRIMARY KEY (creator_id, category_id)
              )')   
  #PRODUCT RELATED
  #products
  db.execute('CREATE TABLE products (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              creator_id INTEGER,
              name TEXT,
              description TEXT,
              base_price INT,
              image TEXT,
              created_at
              )')  
  #product_options (Size, Color, Addon)
  db.execute('CREATE TABLE options_types (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT
              )') 
  #product_options_values (S, M, L, or Black, Red or Custom Text)
  db.execute('CREATE TABLE option_values (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              product_option_type_id INTEGER,
              value TEXT,
              price_modifier INTEGER
              )') 
  #product_option_types (links products to the options they have)
  db.execute('CREATE TABLE product_option_types (
              product_id INTEGER,
              option_type_id INTEGER,
              PRIMARY KEY (product_id, option_type_id)
              )') 

  #ORDERS
  db.execute('CREATE TABLE orders (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER,
              total_price INTEGER,
              created_at TEXT
            )')

  #Order_items
  db.execute('CREATE TABLE order_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              order_id INTEGER,
              product_id INTEGER,
              quantity INTEGER,
              price_at_purchase INTEGER
            )')

  #Reviews
  db.execute('CREATE TABLE reviews (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER,
              product_id INTEGER,
              rating INTEGER,
              comment TEXT,
              created_at TEXT
            )')

  #VOTES
  db.execute('CREATE TABLE votes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER,
              creator_id INTEGER,
              created_at TEXT
            )')

end




def populate_tables(db)
  #USERS
  db.execute('INSERT INTO users (username, email, pwd_digest) VALUES ("example_name", "example@gmail", "example_password")')

  #CATEGORIES
  db.execute('INSERT INTO categories (name) VALUES ("Gaming")')
  db.execute('INSERT INTO categories (name) VALUES ("Streamer")')
  db.execute('INSERT INTO categories (name) VALUES ("Minecraft")')

  #CREATORS
  db.execute("INSERT INTO creators (name, username, about_me, theme_color) VALUES (Dream,'dream','Minecraft Creator', 'light_green')")
  db.execute("INSERT INTO creators (creator_id, platform, username, followers) VALUES (PewDiePie,'pewdiepie','OG Youtube Legend', 'red')")

  #SOCIAL_MEDIA
  db.execute("INSERT INTO social_medias (creator_id, platform, username, followers) VALUES (1,'YouTube','dream',31000000)")
  db.execute("INSERT INTO social_medias (creator_id, platform, username, followers) VALUES (2,'YouTube','pewdiepie',111000000)")
  db.execute("INSERT INTO social_medias (creator_id, platform, username, followers) VALUES (1,'Twitch','kaicenat',156000)")


  #CREATOR_CATEGORIES
  db.execute('INSERT INTO creator_categories (creator_id, category_id) VALUES (1,3)')
  db.execute('INSERT INTO creator_categories (creator_id, category_id) VALUES (2,1)')

  #PRODUCTS
  db.execute('INSERT INTO products (creator_id, name, description, base_price) VALUES (1, "Dream Hoodie", "Cool Minecraft Hoodie for Dream fans", 50)')
  db.execute('INSERT INTO products (creator_id, name, description, base_price) VALUES (1, "PewDiePie T-Shirt", "Cool Minecraft Hoodie for Dream fans", 50)')

  #OPTIONS_TYPES
  db.execute('INSERT INTO option_types (name) VALUES ("Size")')
  db.execute('INSERT INTO option_types (name) VALUES ("Color")')
  db.execute('INSERT INTO option_types (name) VALUES ("Addon")')
  db.execute('INSERT INTO option_types (name) VALUES ("Quote")')

  #OPTION_VALUES

  #PRODUCT_OPTION_TYPES

  #ORDERS

  #ORDER_ITEMS

  #REVIEWS

  #VOTES
end


seed!(db)





