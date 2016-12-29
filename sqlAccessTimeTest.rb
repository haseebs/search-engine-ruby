require 'mysql'

connection = Mysql.new 'localhost', 'test', '12345', 'wikiDatabase'
sqlStatementGetWordID = connection.query "SELECT * FROM Lexicon"

wordID = {}
sqlStatementGetWordID.num_rows.times do
  row = sqlStatementGetWordID.fetch_row
  wordID[row[1].upcase] = row[0]
end

puts wordID['CHINA']

