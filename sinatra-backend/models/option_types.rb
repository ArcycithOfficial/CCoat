class OptionType
  def self.all(db)
    db.execute("SELECT * FROM option_types")
  end

  def self.create(db, name)
    db.execute("INSERT INTO option_types (name) VALUES (?)", name)
    db.execute("SELECT last_insert_rowid() AS id").first["id"]
  end

  def self.delete(db, id)
    db.execute("DELETE FROM option_types WHERE id = ?", id)
  end
end