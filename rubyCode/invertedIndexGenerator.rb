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

#rowLimit = 5000
wordID = 0;
maxWordID = connection.query("SELECT max(wordID) FROM forwardIndex;").fetch_row[0].to_i
#lastID = 0

puts 'Adding index to forwardIndex temporarily to ensure quicker retrieval of data'
#connection.query("ALTER TABLE forwardIndex DROP INDEX fwi")
connection.query("CREATE INDEX fwi ON forwardIndex(wordID)")
while wordID <= maxWordID
  forwardIndex = connection.query("SELECT * FROM forwardIndex where wordID = #{wordID}")

  nDocs = forwardIndex.num_rows

  if nDocs == 0
    wordID += 1
    next
  end

  forwardIndex.num_rows.times do
    row = forwardIndex.fetch_row
    rows.push( Row.new( row[1], 0, row[0], row[2], row[3] ) )
  end

  #Assign nDocs value to their places
    rows.each do |row|
      row.nDocs = nDocs
    end

  #Generate inverted Index sql file
  GenSQL.generateInverted( rows, File.expand_path("..", Dir.pwd) + '/repository/invertedIndexData.sql' )

  puts "Processed #{wordID}/#{maxWordID}"
  wordID += 1
  forwardIndex.free
  rows.clear
end

puts "Removing Index from forwardIndex"
connection.query("ALTER TABLE forwardIndex DROP INDEX fwi;")

puts "Removing Index from invertedIndex so our newly generated data may be inserted quickly"
connection.query("ALTER TABLE invertedIndex DROP INDEX wordID_index;")

# Write into sql file to add back the wordID index on invertedIndex so it is ready to use
file = File.open(File.expand_path("..", Dir.pwd) + '/repository/invertedIndexData.sql', 'a+')
file.write("CREATE INDEX wordID_index ON invertedIndex(wordID);")

