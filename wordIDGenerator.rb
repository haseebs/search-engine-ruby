# Creates connection with mysql server and then builds the word dictionary
# These words are then inserted into database which rejects duplicate entries
# These unique entries are then used to map words to wordIDs in a new table called
# lexicon. Progress is printed as the process goes on
require 'mysql'
require 'nokogiri'

# Parameters = host, username, password, database name
connection = Mysql.new 'localhost', 'test', '12345', 'wikiDatabase'

# Open the file and parse it with nokogiri
file = Nokogiri::XML(File.open('simplewiki-20161220-pages-meta-current.xml'))

# Builds the dictionary in mySQL db
# The regex given extracts proper words from the text tag in XML
# document. The Regex is first splitting the string based on whitespace
# and any non-word character. It then selects elements from that array
# which consist of word characters and pushes them to database
prepare = connection.prepare 'INSERT IGNORE INTO Dictionary VALUES(?)'
file.css('text').each_with_index do |page, count|
  page.text.to_s.split(/[\s\W]/).select{|word| word =~ /^\w+$/}.each do |extractedWord|
    prepare.execute extractedWord
    puts "Building dictionary #{count}"
  end
end

# Close the prepare connection
prepare.close

# Maps words to wordIDs in new table by using data generated above.
# The regex given removes the [" "] from around the words returned
# by the database
count = 0
prepare = connection.prepare 'INSERT INTO Lexicon(word) VALUES(?)'
response = connection.query 'SELECT * FROM Dictionary'
numRow = response.num_rows
numRow.times do
  prepare.execute response.fetch_row.to_s[/\w+/]
  count = count + 1
  puts "Generating lexicon for word #{count}/#{numRow}"
end

# Close the connection
connection.close
