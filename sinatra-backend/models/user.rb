class User
  def self.find_by_email(db, email)
    db.execute("SELECT * FROM users WHERE email = ?", email).first
  end

  def self.create(db, username, email, password_digest)
    db.execute("INSERT INTO users(username, email, pwd_digest, role) VALUES (?, ?, ?, ?)",
      [username, email, password_digest, "user"])
  end

  def self.all(db)
    db.execute("SELECT id, username, email, role FROM users")
  end
end