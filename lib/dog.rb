require 'pry'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(hash)
    @id = hash[:id]
    @name = hash[:name]
    @breed = hash[:breed]
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, @name, @breed, @id)
  end

  def self.find_or_create_by(hash)
    entry = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])[0]
    if entry
      self.new_from_db(entry)
    else
      self.create(hash)
    end
  end

  def self.find_by_name(name)
    entry = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    self.new_from_db(entry)
  end

  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
  end

  def self.new_from_db(row)
    self.create({id:row[0], name:row[1], breed:row[2]})
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    new_entry = DB[:conn].execute(sql, id)[0]
    self.new_from_db(new_entry)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    to_find = DB[:conn].execute(sql)[0]

  end
end
