require './hits'
require 'mysql'
require './GenSQL'

#This function takes the processed data and path to the file where it will store
#generate an sql file which contains data for forward Index.Sql file was generated
#instead of using the ruby mysql gem because of the massive performance improvement
#achieved by executing the generated sql file versus using mysql gem (80x faster in our case)
#This function also calculates the number of hits for each word in each document
def finalize(rows, reservedFiles)
  #Calculate nhits
  nhits = Hash.new 0
  rows.each do |row|
    nhits[row.docID.to_s + row.wordID.to_s] += 1
  end

  #
  rows.each do |row|
    row.nHits = nhits[row.docID.to_s + row.wordID.to_s]
  end

  #Push to database
  #This method below works but it is very expensive
  #sqlStatementInsert = $connection.prepare 'INSERT INTO forwardIndex(docID, wordID, nHits, hit) VALUES(?,?,?,?)'
  #rows.each do |row|
  #  sqlStatementInsert.execute(row.docID, row.wordID, row.nHits, row.hit)
  #end
  #So instead we generate our own sql file which then can be executed for quicker insertion
  GenSQL.generate(rows, reservedFiles)
end

#Parameters = host, username, password, database name
$connection = Mysql.new 'localhost', 'test', '12345', 'wikiDatabase'

#Get words and their corresponding wordIDs from the database and store them in
#a hash. This operation takes approx 2.5 seconds on our computer. This was done
#because sending queries repeatedly for each word is a very expensive operation
#(It would have taken 10-30 weeks instead of 2.5 seconds for this task on entire dataset)
sqlStatementGetWordID = $connection.query "SELECT * FROM Lexicon"
wordID = {}
sqlStatementGetWordID.num_rows.times do
  row = sqlStatementGetWordID.fetch_row
  wordID[row[1].upcase] = row[0]
end

Row = Struct.new(:docID, :wordID, :nHits, :hit)
rows = []
#Also we can read from forwardIndex and store in this struct for when extending the dataset

#Get the parent directory and then direct to repository folder. The data related to search
#will be stored in this folder
folder = File.expand_path("..", Dir.pwd) + '/repository/'

#Delete forwardIndexData.sql and invertedIndexData.sql if they already exist
%x[rm #{folder}forwardIndexData.sql]
%x[rm #{folder}invertedIndexData.sql]

#Dont check the files for forward and inverted indexes (in case the above commands fail)
reservedFiles = [folder+'forwardIndexData.sql', folder+'invertedIndexData.sql']

#Linux/Unix shell command to count the total number of files in a given directory.
#Used to show progess
totalFiles = %x[ls -l #{folder} | egrep -c '^-']
fileCounter = 0

#Get array of filenames in the selected folder
filenames = Dir.glob(folder+ '**')
filenames -= reservedFiles

#Iterate over each file
filenames.each do |filename|

  #Once we have iterated over specified number of files, we write their data to disk and
  #clear the array to deallocate the memory. This is done to improve speed and reduce 
  #memory usage. The number can be adjusted.
  if fileCounter % 5000 == 0
    finalize(rows, reservedFiles[0])
    rows.clear
  end
  #Show progress
  puts "Indexing file: #{fileCounter+=1}/#{totalFiles}"
  #Get text
  text = File.open(filename, 'r').read.to_s
  #Get title
  title = filename.gsub(folder, '').match( /-(.*)-/ )[1].gsub(/_/, ' ').split(/[\s\W]/)
  #Get docID
  docID = filename.gsub(folder, '').match(/(.*?)-/)[1].to_i

  #Get all bold words and split them wrt non-word characters
  boldWords = []
  text.scan(/'''(.*?)'''/).each_with_index do |word, index|
    boldWords[index] = word[0].split(/[\s\W]/)
  end

  #Push title as fancy hit
  title.each do |word|
    word.upcase!
    rows.push(Row.new(docID, wordID[word], 0, Hits.newHit(0,2,0))) if wordID[word] != NIL
  end

  count = 0
  boldWordsIndex = 0;
  #Get all remaining words, substitute a string 'PH321' in place of bold words so that they
  #are not counted twice. We use this string as a placeholder for the position of bold word
  #The regex below then splits the string on basis of whitespaces and non-word characters and
  #then from the resulting array, selects those elements which consist of one or more word characters
  text.gsub(/'''(.*?)'''/, 'PH321').split(/[\s\W]/).select{|word| word =~ /^\w+$/}.each_with_index do |word, index|

    if word == 'PH321'
      #Here we check whether a boldWord is a single word or a combination of words separated by some whitespac
      #or other type of delimiter. We then assign them their position accordingly
      if boldWords[boldWordsIndex].class == String
        boldWords[boldWordsIndex].upcase!
        wordIDbold = wordID[boldWords[boldWordsIndex]]
        rows.push(Row.new(docID, wordIDbold, 0, Hits.newHit(0,1,count+=1))) if wordIDbold != NIL
        boldWordsIndex+=1
        next
      end

      if boldWords[boldWordsIndex].class == Array
        boldWords[boldWordsIndex].each do |boldWord|
          boldWord.upcase!
          wordIDbold = wordID[boldWord]
          rows.push(Row.new(docID, wordIDbold, 0, Hits.newHit(0,1,count+=1))) if wordIDbold != NIL
        end
        boldWordsIndex+=1
        next
      end
      next
    end

    #Check for capital and normal words and push them
    caps = 0
    caps = 1 if word == word.upcase && word =~ /[a-zA-Z]/
    word.upcase!
    wordIDrest = wordID[word]
    next if wordIDrest == NIL
    rows.push(Row.new(docID, wordIDrest, 0, Hits.newHit(caps, 0, count+=1)))
  end
end

#Write the rest of the data currently in the memory into the file
finalize(rows, reservedFiles[0])
