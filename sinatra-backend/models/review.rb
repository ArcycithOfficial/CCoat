class Review
  def self.for_product(db, product_id)
    db.execute("SELECT * FROM reviews WHERE product_id = ?", product_id)
  end


  def self.find(db, id)
    db.execute("SELECT * FROM reviews WHERE id = ?", id).first
  end

  def self.create(db, user_id, product_id, rating, comment)
    db.execute("INSERT INTO reviews (user_id, product_id, rating, comment, created_at) VALUES(?, ?, ?, ?, ?)",
      [user_id, product_id, rating, comment, Time.now.to_s])
    db.execute("SELECT last_insert_rowid() AS id").first["id"]
  end

  def self.update(db, id, product_id, rating, comment)
    db.execute("UPDATE reviews SET rating = ?, comment = ? WHERE id = ? AND product_id = ?",
      [rating, comment, id, product_id])
    db.execute("SELECT * FROM reviews WHERE id = ?", id).first
  end

  def self.delete(db, id, product_id)
    db.execute("DELETE FROM reviews WHERE id = ? AND product_id = ?", [id, product_id])
  end
end