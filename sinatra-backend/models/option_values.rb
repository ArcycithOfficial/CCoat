class OptionValue
  def self.for_type(db, option_type_id)
    db.execute("SELECT * FROM option_values WHERE option_type_id = ?", option_type_id)
  end

  def self.create(db, option_type_id, value, price_modifier)
    db.execute("INSERT INTO option_values (option_type_id, value, price_modifier) VALUES (?, ?, ?)",
      [option_type_id, value, price_modifier])
    db.execute("SELECT last_insert_rowid() AS id").first["id"]
  end

  def self.update(db, id, value, price_modifier)
    db.execute("UPDATE option_values SET value = ?, price_modifier = ? WHERE id = ?",
      [value, price_modifier, id])
  end

  def self.delete(db, id)
    db.execute("DELETE FROM option_values WHERE id = ?", id)
  end
end