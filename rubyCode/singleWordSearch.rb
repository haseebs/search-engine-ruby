require 'matrix'
require 'mysql'
require './hits.rb'

#Parameters = host, user, password, databasename
connection = Mysql.new 'localhost', 'test', '12345', 'wikiDatabase'

# [title, capitalization, bold, plain]
TYPE_WEIGHT = Vector[20, 10, 8, 1]

puts 'Enter a search term'
word = gets.chomp
word.downcase!

docresp = connection.query("SELECT docID, hit from invertedIndex where wordID = ( SELECT wordID from Lexicon where word = '#{word}' LIMIT 1 );")
hits = []
Hit = Struct.new(:docID, :hit)

docresp.num_rows.times do
  row = docresp.fetch_row
  hits << Hit.new(row[0], row[1])
end

#TypeCount = Struct.new(:docID, :vector)
typeCounts = {}

IR = Struct.new(:docID, :ir)
irScore = []

hits.each do |doc|
  cap, imp, pos = Hits.extractHit(doc.hit)

  title = 0
  bold = 0
  plain = 0

  title = 1 if imp == 2
  bold = 1 if imp == 1
  plain = 1 if imp == 0

  if typeCounts[doc.docID].nil?
    typeCounts[doc.docID] = Vector[title, cap, bold, plain] #= TypeCount.new(doc.docID, Vector[title, cap, bold, plain])
    next
  end
  typeCounts[doc.docID] += Vector[title, cap, bold, plain]
end

#Dot product with Typeweight vector
typeCounts.each do |id, vec|
  irScore << IR.new(id, TYPE_WEIGHT.inner_product(vec))
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

