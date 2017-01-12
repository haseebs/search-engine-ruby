require './multiWordHelper.rb'
require 'mysql'
require 'matrix'
require './hits.rb'

module MultiWordSearch
  class << self
    Hit = Struct.new(:word, :hit)
    IR = Struct.new(:docID, :ir)
    def search(words)
      #Parameters = host, user, password, databasename
      connection = Mysql.new 'localhost', 'test', '12345', 'wikiDatabase'

      docIDs = []
      hits = {}

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
      filenames = []
      sortedScores.each do |doc|
        name = connection.query("SELECT title, wordCount from docRefs where docID = '#{doc.docID}' LIMIT 1;").fetch_row
        filenames << [doc.docID, name[0], name[1]].join('-')
      end
      #puts filenames
      return filenames
    end
  end
end

