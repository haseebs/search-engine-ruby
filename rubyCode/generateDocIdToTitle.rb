# Generates docID, title and wordCount to store them in the database
# So we can generate filenames when we are given docID

#including ruby library nokogiri and mysql
require 'nokogiri'     
require 'mysql'

#creating connection to mysql 
#Parameters = host, username, password, database name
connection = Mysql.new 'localhost', 'test', '12345', 'wikiDatabase'
sqlStatement= connection.prepare 'INSERT INTO docRefs(docID, title, wordCount) VALUES(?,?,?)'

#opening the simple wikipeia xml file
file = Nokogiri::XML(File.open(File.open(File.expand_path("..", Dir.pwd) + '/simplewiki-20161220-pages-meta-current.xml'))


file.css('page').each do |page|
  text = page.css('text')

  #counting number of words in every page
  wordCount = text.to_s.split.size

  #id is the docID of everypage, which is already assigned on simple wikipedia
  id = page.css('id')[0].text.to_s

  #title of every page
  title = page.css('title')[0].text
  #if a page has no title or '/' then assigning it title 'redirect'
  title = 'redirect' if title == nil or title == '/'

  #removing '/' from title and inserting '_' in their place
  splitTitle = title.to_s.split('/').first
  splitTitle.gsub! /\s+/,'_'

  sqlStatement.execute id, splitTitle, wordCount
end
