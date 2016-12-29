require 'mysql'
require './hits'
require './GenSQL'

#Create new data structure for storing row data and
#create an array to store these structures in
Row = Struct.new(:wordID, :nDocs, :docID, :nHits, :hit)
rows = []

#Parameters = host, user, password, databasename
connection = Mysql.new 'localhost', 'test', '12345', 'wikiDatabase'

#Get data from forward Index and load it into memory and then
#fill it in our newly created data structure
#This will be further optimized in the future to take less memory
#but for a small dataset, this method is generally faster
forwardIndex = connection.query "SELECT * FROM forwardIndex order by wordID asc"
forwardIndex.num_rows.times do
  row = forwardIndex.fetch_row
  rows.push( Row.new( row[1], 0, row[0], row[2], row[3] ) )
end

#Count nDocs for each wordID
nDocs = Hash.new 0
rows.each do |row|
  nDocs[row[0]] += 1
end

#Assign nDocs value to their places
rows.each do |row|
  row.nDocs = nDocs[row[0]]
end

#Generate inverted Index sql file
GenSQL.generateInverted( rows, File.expand_path("..", Dir.pwd) + '/repository/invertedIndexData.sql' )
