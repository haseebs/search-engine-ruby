require './hits'
require 'mysql'

# Parameters = host, username, password, database name
$connection = Mysql.new 'localhost', 'test', '12345', 'wikiDatabase'
sqlStatementInsert = $connection.prepare 'INSERT INTO forwardIndex(docID, wordID, nHits, hit) VALUES(?,?,?,?)'

def getWordID(word)
  sqlStatementGetWordID = $connection.query "SELECT wordID FROM Lexicon WHERE word = '#{word}'"
  wordID = sqlStatementGetWordID.fetch_row.to_s.to_i
end

def getnHits(docID, wordID)
  sqlGetnHits = $connection.query "SELECT count(nHits) FROM forwardIndex WHERE docID = '#{docID}' and wordID = '#{wordID}'"
  nHits = sqlGetnHits.fetch_row.to_s.to_i + 1
end

folder = File.expand_path("..", Dir.pwd) + '/smallrepo/**'
filenames = Dir.glob(folder)

filenames.each do |filename|

  #Get text
  text = File.open(filename, 'r').read.to_s
  #Get title
  title = filename.gsub(folder, '').match( /-(.*)-/ )[1].gsub(/_/, ' ')
  #Get docID
  docID = filename.gsub(folder, '').match(/(.*?)-/)[1].to_i

  #Get all bold words
  boldWords = []
  text.scan(/'''(.*?)'''/).each_with_index do |word, index|
    boldWords[index] = word[index][0].split(/[\s,\W]/)
  end

  #Push title as fancy hit
  wordID = getWordID(title)
  sqlStatementInsert.execute docID, wordID, getnHits(docID, title), Hits.newHit(0,2,0)
  count = 0
  boldWordsIndex = 0;
  #Get all remaining words
  text.gsub(/'''(.*?)'''/, 'PH321').split(/[\s,\W]/).select{|_w| _w =~ /^\w+$/}.each_with_index do |word, index|

    if word == 'PH321'
      if boldWords[boldWordsIndex].class == String
        wordID = getWordID(boldWords[boldWordsIndex])
        sqlStatementInsert.execute docID, wordID, getnHits(docID, boldWords[boldWordsIndex]), Hits.newHit(0,1,count+=1)
        boldWordsIndex+=1
        next
      end

      if boldWords[boldWordsIndex].class == Array
        boldWords[boldWordsIndex].each do |boldWord|
          wordID = getWordID(boldWords[boldWordsIndex])
          sqlStatementInsert.execute docID, wordID, getnHits(docID, boldWords[boldWordsIndex]), Hits.newHit(0,1,count+=1)
        end
        boldWordsIndex+=1
        next
      end
    end

    #Check caps
    caps = 0
    caps = 1 if word == word.upcase && word =~ /[a-zA-Z]/
    wordID = getWordID(word)
    sqlStatementInsert.execute docID, wordID, getnHits(docID, wordID), Hits.newHit(caps, 0, count+=1)
  end
end

close sqlStatementInsert
close $connection
