require './multiWordHelper.rb'
require 'mysql'
require 'matrix'
require './hits.rb'

#Parameters = host, user, password, databasename
connection = Mysql.new 'localhost', 'test', '12345', 'wikiDatabase'

puts 'Enter a search term'
words = gets.chomp
words = words.downcase.split
numWords = words.count

docIDs = []
hits = {}
Hit = Struct.new(:word, :hit)

words.each_with_index do |word, index|
  docresp = connection.query("SELECT docID, hit from invertedIndex where wordID = ( SELECT wordID from Lexicon where word = '#{word}' LIMIT 1 );")

  docresp.num_rows.times do
    row = docresp.fetch_row
    if hits[row[0]].nil?
      hits[row[0]] = []
    end
    if docIDs[index].nil?
      docIDs[index] = []
    end
    #store docID-> [word in query, hit]
    hits[row[0]] << Hit.new(index, row[1])
    #store word in query -> docID
    docIDs[index] << row[0]
  end
end

docsHasAllWords = docIDs[0]
docIDs.each_with_index do |doc, index|
  next if index == 0
  docsHasAllWords = doc & docsHasAllWords
end

IR = Struct.new(:docID, :ir)
irScore = []

docsHasAllWords.each do |docID|
  positionVectors = []
  type = []
  hitinDoc = hits[docID]
  hitinDoc.each do |aHit|
    cap, imp, pos = Hits.extractHit(aHit.hit)

    positionVectors[aHit.word] = [] if positionVectors[aHit.word].nil?
    type[aHit.word] = [] if type[aHit.word].nil?

    positionVectors[aHit.word] << pos
    type[aHit.word] << MultiWordHelper.type(cap, imp)
  end
  proximityWeight = MultiWordHelper.proximity(positionVectors)
  typeWeight = MultiWordHelper.typeWeight(type)
  finalWeight = [proximityWeight, typeWeight].transpose.map { |x| x.reduce(:+) }
  ir = finalWeight.reduce(:+)

  irScore << IR.new(docID, ir)
end


#Sort is inefficient, needs to be optimized
sortedScores = irScore.sort_by { |a| a[:ir] }.reverse[0..1000]
#
#To make this portion more efficient, load docRefs into RAM at
#the start of program, its about only 100mb
sortedScores.each do |doc|
  print doc
  puts connection.query("SELECT title from docRefs where docID = '#{doc.docID}' LIMIT 1;").fetch_row
end

