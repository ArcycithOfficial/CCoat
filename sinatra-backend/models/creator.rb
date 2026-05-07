class Creator
  def self.all(db)
    db.execute("SELECT 
      creators.*, json_group_array(DISTINCT creator_categories.category_id) AS category_ids,
      GROUP_CONCAT(DISTINCT categories.name) AS category_names
      FROM creators
      LEFT JOIN creator_categories ON creators.id = creator_categories.creator_id
      LEFT JOIN categories ON categories.id = creator_categories.category_id
      GROUP BY creators.id")
  end

  def self.find(db, id)
    db.execute("SELECT * FROM creators WHERE id = ?", id).first
  end

  def self.create(db, data)
    db.execute("INSERT INTO creators(name, username, real_name, nationality, age, about_me, profile_image, banner_image, theme_color, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [data["name"], data["username"], data["real_name"], data["nationality"],
       data["age"], data["about_me"], data["profile_image"], data["banner_image"],
       data["theme_color"], Time.now.to_s])
    db.execute("SELECT last_insert_rowid() AS id").first["id"]
  end

  def self.update(db, id, data)
    db.execute("UPDATE creators SET name = ?, username = ?, real_name = ?, nationality = ?,
      age = ?, about_me = ?, profile_image = ?, banner_image = ?, theme_color = ?, updated_at = ? WHERE id = ?",
      [data["name"], data["username"], data["real_name"], data["nationality"],
       data["age"], data["about_me"], data["profile_image"], data["banner_image"],
       data["theme_color"], Time.now.to_s, id])
  end

  def self.delete(db, id)
    db.execute("DELETE FROM creators WHERE id = ?", id)
  end

  def self.categories(db, creator_id)
    db.execute("SELECT categories.name, categories.id FROM categories 
                JOIN creator_categories ON categories.id = creator_categories.category_id 
                WHERE creator_categories.creator_id = ?", creator_id)
  end

  def self.add_category(db, creator_id, category_id)
    db.execute("INSERT INTO creator_categories(creator_id, category_id) VALUES (?, ?)", [creator_id, category_id])
  end

  def self.remove_category(db, creator_id, category_id)
    db.execute("DELETE FROM creator_categories WHERE creator_id = ? AND category_id = ?", [creator_id, category_id])
  end
end