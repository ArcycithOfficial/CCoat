class Social
  def self.for_creator(db, creator_id)
    db.execute("SELECT * FROM social_medias WHERE creator_id = ?", creator_id)
  end
end