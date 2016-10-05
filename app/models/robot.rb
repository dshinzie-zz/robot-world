require 'sqlite3'

class Robot

  attr_reader :name, :city, :state, :department, :id

  def initialize(robot_params)
    @name = robot_params["name"]
    @city = robot_params["city"]
    @state = robot_params["state"]
    @department = robot_params["department"]
    @database = SQLite3::Database.new('db/robot_world_development.db')
    @database.results_as_hash = true
    @id = robot_params["id"] if robot_params["id"]
  end

  def save
    @database.execute("INSERT INTO robots (name, city, state, department) values(?, ?, ?, ?);", @name, @city, @state, @department)
  end

  def self.database
    database = SQLite3::Database.new('db/robot_world_development.db')
    database.results_as_hash = true
    database
  end

  def self.all
    database
    robots = database.execute("SELECT * FROM robots")
    robots.map do |robot|
      Robot.new(robot)
    end
  end

  def self.find(id)
    database
    robot = database.execute("SELECT * FROM robots WHERE id = ?", id).first
    Robot.new(robot)
  end

  def self.update(id, robot_params)
    database
    database.execute("UPDATE robots
                      SET name = ?,
                          city = ?,
                          state = ?,
                          department = ?
                      WHERE id = ?;",
                      robot_params[:name],
                      robot_params[:city],
                      robot_params[:state],
                      robot_params[:department],
                      id)

    Robot.find(id)
  end

  def self.destroy(id)
    database
    database.execute("DELETE FROM robots
                      WHERE id = ?;", id)
  end

  def self.total
    database
    database.execute("SELECT COUNT(id) FROM robots;").first["COUNT(id)"]
  end

  def self.group_state
    database
    results = database.execute("SELECT state, COUNT(id) FROM robots GROUP BY state;")

    results.reduce({}) do |result, hash|
      result[hash["state"]] = hash["COUNT(id)"]
      result
    end
  end

  def self.group_city
    database
    results = database.execute("SELECT city, COUNT(id) FROM robots GROUP BY city;")

    results.reduce({}) do |result, hash|
      result[hash["city"]] = hash["COUNT(id)"]
      result
    end
  end

  def self.group_department
    database
    results = database.execute("SELECT department, COUNT(id) FROM robots GROUP BY department;")

    results.reduce({}) do |result, hash|
      result[hash["department"]] = hash["COUNT(id)"]
      result
    end
  end

end
