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
  db.execute('DROP TABLE IF EXISTS products')
  db.execute('DROP TABLE IF EXISTS option_types')
  db.execute('DROP TABLE IF EXISTS option_values')
  db.execute('DROP TABLE IF EXISTS product_option_types')
  db.execute('DROP TABLE IF EXISTS orders')
  db.execute('DROP TABLE IF EXISTS order_items')
  db.execute('DROP TABLE IF EXISTS reviews')
  db.execute('DROP TABLE IF EXISTS reviews_likes')
  db.execute('DROP TABLE IF EXISTS votes')
end

def create_tables(db)
  #users
  db.execute('CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL, 
              email TEXT NOT NULL,
              pwd_digest TEXT NOT NULL,
              created_at TEXT DEFAULT CURRENT_TIMESTAMP,
              profile_picture TEXT
              )')
  #creators
  db.execute('CREATE TABLE creators (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              username TEXT NOT NULL UNIQUE,
              real_name TEXT, 
              nationality TEXT, 
              age integer,
              about_me TEXT,
              profile_image TEXT,
              banner_image TEXT,
              created_at TEXT DEFAULT CURRENT_TIMESTAMP,
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
              platform TEXT NOT NULL,
              username TEXT NOT NULL,
              followers INTEGER,
              views INTEGER
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
              creator_id INTEGER NOT NULL,
              name TEXT NOT NULL,
              description TEXT NOT NULL,
              base_price INTEGER NOT NULL,
              image TEXT,
              created_at TEXT DEFAULT CURRENT_TIMESTAMP
              )')  
  #product_options (Size, Color, Addon)
  db.execute('CREATE TABLE option_types (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL
              )') 
  #product_options_values (S, M, L, or Black, Red or Custom Text)
  db.execute('CREATE TABLE option_values (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              option_type_id INTEGER,
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
  db.execute("CREATE TABLE orders (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER,
              total_price INTEGER,
              status TEXT DEFAULT 'pending',
              created_at TEXT DEFAULT CURRENT_TIMESTAMP
            )")

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
              created_at TEXT DEFAULT CURRENT_TIMESTAMP,
              updated_at TEXT
            )')

  db.execute('CREATE TABLE reviews_likes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              review_id INTEGER,
              user_id INTEGER,
              liked BOOLEAN DEFAULT 1,
              UNIQUE (review_id, user_id)
            )')            

            

  #VOTES
  db.execute('CREATE TABLE votes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER,
              creator_id INTEGER,
              created_at TEXT,
              UNIQUE (user_id, creator_id)
            )')
end




def populate_tables(db)
  #USERS
  db.execute('INSERT INTO users (username, email, pwd_digest) VALUES ("example_name", "example@gmail", "example_password")')
  db.execute('INSERT INTO users (username, email, pwd_digest) VALUES ("example_name2", "example2@gmail", "example2_password")')

  #CATEGORIES
  db.execute('INSERT INTO categories (name) VALUES ("Gaming")')
  db.execute('INSERT INTO categories (name) VALUES ("Streamer")')
  db.execute('INSERT INTO categories (name) VALUES ("Minecraft")')

  #CREATORS
  db.execute("INSERT INTO creators (name, username, about_me, theme_color, profile_image, banner_image) VALUES ('Dream','dream','Minecraft Creator', 'light_green', '/images/dream.jpg', '/images/dream-banner.png')")
  db.execute("INSERT INTO creators (name, username, about_me, theme_color, profile_image, banner_image) VALUES ('PewDiePie','pewdiepie','OG Youtube Legend', 'red','/images/pewdiepie.jpg', '/images/pewdiepie-banner.png')")

  #SOCIAL_MEDIA
  db.execute("INSERT INTO social_medias (creator_id, platform, username, followers) VALUES (1,'YouTube','dream',31000000)")
  db.execute("INSERT INTO social_medias (creator_id, platform, username, followers) VALUES (2,'YouTube','pewdiepie',111000000)")
  db.execute("INSERT INTO social_medias (creator_id, platform, username, followers) VALUES (1,'Twitch','kaicenat',156000)")


  #CREATOR_CATEGORIES
  db.execute('INSERT INTO creator_categories (creator_id, category_id) VALUES (1,3)')
  db.execute('INSERT INTO creator_categories (creator_id, category_id) VALUES (2,1)')

  #PRODUCTS
  db.execute('INSERT INTO products (creator_id, name, description, base_price) VALUES (1, "Dream Hoodie", "Cool Minecraft Hoodie for Dream fans", 50)')
  db.execute('INSERT INTO products (creator_id, name, description, base_price) VALUES (2, "PewDiePie T-Shirt", "Cool Minecraft Hoodie for Dream fans", 50)')

  #OPTIONS_TYPES
  db.execute('INSERT INTO option_types (name) VALUES ("Size")')
  db.execute('INSERT INTO option_types (name) VALUES ("Color")')
  db.execute('INSERT INTO option_types (name) VALUES ("Addon")')
  db.execute('INSERT INTO option_types (name) VALUES ("Quote")')

  #OPTION_VALUES
  db.execute('INSERT INTO option_values (option_type_id, value,price_modifier) VALUES (1,"S",0)')
  db.execute('INSERT INTO option_values (option_type_id, value,price_modifier) VALUES (1,"M",0)')
  db.execute('INSERT INTO option_values (option_type_id, value,price_modifier) VALUES (1,"L",5)')
  db.execute('INSERT INTO option_values (option_type_id, value,price_modifier) VALUES (2,"Black",0)')
  db.execute('INSERT INTO option_values (option_type_id, value,price_modifier) VALUES (2,"Red",0)')
  db.execute('INSERT INTO option_values (option_type_id, value,price_modifier) VALUES (3,"Custom Text",10)')


  #PRODUCT_OPTION_TYPES
  db.execute('INSERT INTO product_option_types (product_id, option_type_id) VALUES (1,1)')
  db.execute('INSERT INTO product_option_types (product_id, option_type_id) VALUES (1,2)')
  db.execute('INSERT INTO product_option_types (product_id, option_type_id) VALUES (1,3)')
  db.execute('INSERT INTO product_option_types (product_id, option_type_id) VALUES (2,2)')

  #ORDERS
  db.execute('INSERT INTO orders (user_id,total_price) VALUES (1,70)')
  db.execute('INSERT INTO orders (user_id,total_price) VALUES (2,20)')

  #ORDER_ITEMS
  db.execute('INSERT INTO order_items (order_id,product_id,quantity,price_at_purchase) VALUES (1,1,1,50)')
  db.execute('INSERT INTO order_items (order_id,product_id,quantity,price_at_purchase) VALUES (1,1,1,20)')
  db.execute('INSERT INTO order_items (order_id,product_id,quantity,price_at_purchase) VALUES (2,2,1,20)')


  #REVIEWS
  db.execute('INSERT INTO reviews (user_id,product_id,rating,comment) VALUES (1,1,5,"Amazing hoodie!")')
  db.execute('INSERT INTO reviews (user_id,product_id,rating,comment) VALUES (2,2,4,"Nice mug!")')

  #VOTES
  db.execute('INSERT INTO votes (user_id,creator_id) VALUES (1,1)')
  db.execute('INSERT INTO votes (user_id,creator_id) VALUES (2,2)')
end


seed!(db)





