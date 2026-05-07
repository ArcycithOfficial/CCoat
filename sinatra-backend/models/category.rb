class Category
  def self.all(db)
    db.execute("SELECT * FROM categories")
  end

  def self.create(db, name)
    db.execute("INSERT INTO categories(name) VALUES (?)", name)
    db.execute("SELECT last_insert_rowid() AS id").first["id"]
  end

  def self.update(db, id, name)
    db.execute("UPDATE categories SET name = ? WHERE id = ?", [name, id])
  end

  def self.delete(db, id)
    db.execute("DELETE FROM categories WHERE id = ?", id)
  end
end