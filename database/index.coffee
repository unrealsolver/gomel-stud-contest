mysql = require 'mysql-co'
config = require 'config'
co = require 'co'

USERS_TABLE = 'Users'
QUIZ_TABLE = "Quiz"
ROLES_TABLE = "Roles"
RESULTS_TABLE = "Results"
FIRST_STEP_TABLE = "FirstStep"

options = config.get('dbConfig')
connection = null

module.exports.createConnection = ->
  connection = mysql.createConnection options

module.exports.getUser = (username) ->
  QUERY = "SELECT * FROM #{USERS_TABLE} WHERE username = ?;"
  connection.query QUERY, [username]

module.exports.getUserById = (id) ->
  QUERY = "SELECT username, firstName, lastName, role FROM #{USERS_TABLE} WHERE id=?;"
  connection.query QUERY, [id]

module.exports.getRole = (id) ->
  QUERY = "SELECT * FROM #{ROLES_TABLE} WHERE id=?;"
  connection.query QUERY, [id]

module.exports.getRoles = ->
  QUERY = "SELECT * FROM #{ROLES_TABLE};"
  connection.query QUERY

module.exports.getAllUsers = ->
  QUERY = "SELECT * FROM #{USERS_TABLE};"
  connection.query QUERY

module.exports.getParticipants = ->
  QUERY = "SELECT * FROM #{USERS_TABLE} WHERE role = (SELECT id FROM #{ROLES_TABLE} WHERE name = 'student');"
  connection.query QUERY

module.exports.saveQuizResults = (result, id) ->
  co ->
    QUERY = "INSERT INTO #{QUIZ_TABLE} (stud_id, task, length, time) VALUE (?,?,?,?)"
    yield connection.query QUERY, [id, result.task, result.selectorLength, result.time]

module.exports.getRoles = ->
  QUERY = "SELECT * FROM #{ROLES_TABLE};"
  connection.query QUERY

module.exports.saveUser = (username, firstName, lastName, roleId, password) ->
  QUERY = "INSERT INTO #{USERS_TABLE} (username, password, firstName, lastName, role) VALUE (?,?,?,?,?)"
  connection.query QUERY, [username, password, firstName, lastName, roleId]

module.exports.removeUser = (id) ->
  QUERY = "DELETE FROM #{USERS_TABLE} WHERE id=?"
  connection.query QUERY, [id]

module.exports.quizResults = ->
  QUERY = "SELECT #{USERS_TABLE}.username, #{USERS_TABLE}.firstName, #{USERS_TABLE}.lastName, #{QUIZ_TABLE}.task, #{QUIZ_TABLE}.length, " +
  "#{QUIZ_TABLE}.time " +
  "FROM #{USERS_TABLE} LEFT JOIN #{QUIZ_TABLE} ON #{QUIZ_TABLE}.stud_id=#{USERS_TABLE}.id " +
  "WHERE #{USERS_TABLE}.role = (SELECT id FROM #{ROLES_TABLE} WHERE name = 'student');"
  connection.query QUERY

module.exports.firstStepResults = ->
  QUERY = "SELECT #{USERS_TABLE}.id, #{USERS_TABLE}.username, #{USERS_TABLE}.firstName, #{USERS_TABLE}.lastName, #{FIRST_STEP_TABLE}.task, " +
  "#{FIRST_STEP_TABLE}.time " + 
  "FROM #{USERS_TABLE} LEFT JOIN #{FIRST_STEP_TABLE} ON #{USERS_TABLE}.id = #{FIRST_STEP_TABLE}.user_id " +
  "WHERE #{USERS_TABLE}.role = (SELECT id FROM #{ROLES_TABLE} WHERE name = 'student');"
  connection.query QUERY

module.exports.commonResults = (step) ->
  QUERY = "SELECT #{USERS_TABLE}.id as userId, #{USERS_TABLE}.firstName, #{USERS_TABLE}.lastName, " + 
  "#{RESULTS_TABLE}.task, #{RESULTS_TABLE}.mark " + 
  "FROM #{USERS_TABLE} LEFT JOIN #{RESULTS_TABLE} ON #{USERS_TABLE}.id=#{RESULTS_TABLE}.user_id AND #{RESULTS_TABLE}.step = ? " +
  "WHERE #{USERS_TABLE}.role = (SELECT id FROM #{ROLES_TABLE} WHERE name = 'student');"
  connection.query QUERY, [step]

module.exports.getUserResults = (userId, step, task) ->
  QUERY = "SELECT * FROM #{RESULTS_TABLE} WHERE user_id = ? AND step = ? AND task = ?;"
  connection.query QUERY, [userId, step, task]

module.exports.changeResultOfCurrentUser = (userId, step, task, value) ->
  QUERY = "UPDATE #{RESULTS_TABLE} SET mark = ? WHERE user_id = ? AND step = ? AND task = ?;"
  connection.query QUERY, [value, userId, step, task]

module.exports.createResultForUser = (userId, step, task, value) ->
  QUERY = "INSERT INTO #{RESULTS_TABLE} (user_id, step, task, mark) VALUE (?,?,?,?);"
  connection.query QUERY, [userId, step, task, value]

module.exports.clearQuizResults = ->
  QUERY = "DELETE FROM #{QUIZ_TABLE};"
  co ->
    yield connection.query QUERY

module.exports.saveFirstStepResults = (userId, taskNumber, time) ->
  QUERY = "INSERT INTO #{FIRST_STEP_TABLE} (user_id, task, time) VALUE (?,?,?);"
  connection.query QUERY, [userId, taskNumber, time]

module.exports.closeConnection = ->
  connection.end()
