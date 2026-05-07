class Product
  #Hämtar alla options för en produkt också
  def self.for_creator(db, creator_id)
    products = db.execute("SELECT * FROM products WHERE creator_id = ?", creator_id)
    products.map do |p|
      option_ids = db.execute("SELECT option_type_id FROM product_option_types WHERE product_id = ?", p["id"])
                    .map { |r| r["option_type_id"] }
      p.merge("option_type_ids" => option_ids)
  end

  end

  def self.find(db, id)
    db.execute("SELECT * FROM products WHERE id = ?", id).first
  end

  def self.options(db, product_id)
    db.execute("SELECT option_types.name AS option_type, option_values.value, option_values.price_modifier 
      FROM product_option_types 
      JOIN option_types ON product_option_types.option_type_id = option_types.id
      JOIN option_values ON option_values.option_type_id = option_types.id
      WHERE product_option_types.product_id = ?", product_id)
  end

  def self.all(db)
    db.execute("SELECT * FROM products")
  end

  def self.create(db, creator_id, data)
    db.execute("INSERT INTO products (creator_id, name, description, base_price, image) VALUES (?, ?, ?, ?, ?)",
      [creator_id, data["name"], data["description"], data["base_price"], data["image"]])
    db.execute("SELECT last_insert_rowid() AS id").first["id"]
  end

  def self.update(db, id, data)
    db.execute("UPDATE products SET name = ?, description = ?, base_price = ?, image = ? WHERE id = ?",
      [data["name"], data["description"], data["base_price"], data["image"], id])
  end

  def self.delete(db, id)
    db.execute("DELETE FROM products WHERE id = ?", id)
  end

  def self.add_option(db, product_id, option_type_id)
    db.execute("INSERT INTO product_option_types (product_id, option_type_id) VALUES (?, ?)",
      [product_id, option_type_id])
  end

  def self.remove_option(db, product_id, option_type_id)
    db.execute("DELETE FROM product_option_types WHERE product_id = ? AND option_type_id = ?",
      [product_id, option_type_id])
  end

    def self.for_creator(db, creator_id)
      products = db.execute("SELECT * FROM products WHERE creator_id = ?", creator_id)
      products.map do |p|
        option_type_ids = db.execute("SELECT option_type_id FROM product_option_types WHERE product_id = ?", p["id"])
                            .map { |r| r["option_type_id"] }
        p.merge("option_type_ids" => option_type_ids)
      end
    end



  def self.option_values(db, product_id)
    db.execute("SELECT option_values.*, option_types.name AS type_name 
      FROM option_values
      JOIN option_types ON option_values.option_type_id = option_types.id
      WHERE option_values.id IN (
        SELECT option_value_id FROM product_option_values WHERE product_id = ?
      )", product_id)
  end

  def self.add_option_value(db, product_id, option_value_id)
    db.execute("INSERT INTO product_option_values (product_id, option_value_id) VALUES (?, ?)",
      [product_id, option_value_id])
  end

  def self.remove_option_value(db, product_id, option_value_id)
    db.execute("DELETE FROM product_option_values WHERE product_id = ? AND option_value_id = ?",
      [product_id, option_value_id])
  end
end


