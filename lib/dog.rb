require_relative "../config/environment.rb"

class Dog
  attr_accessor :id, :name, :breed

  def initialize(dogs)
    # attributes(dogs[:breed],dogs[:name],dogs[id])
    @id = dogs[:id]
    @name = dogs[:name]
    @breed = dogs[:breed]
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if @id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
  end

  def self.find_by_id(id)
      sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |dog|
      self.new_from_db(dog)
    end.first
  end

  def self.find_by_name(name)
      sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |dog|
      self.new_from_db(dog)
    end.first
  end

  def self.new_from_db(row)
    new_dog = Dog.new(name:row[1], breed:row[2], id:row[0])
    new_dog.id = row[0]
    new_dog.name = row[1]
    new_dog.breed = row[2]
    new_dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, @name, @breed, @id)
  end

  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(name:dog_data[1], breed:dog_data[2], id:dog_data[0])
    else
      dog = self.create(hash)
    end
    dog
  end
end
