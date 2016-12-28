# Generates docID, title and wordCount to store them in the database
# So we can generate filenames when we are given docID
require 'nokogiri'
require 'mysql'

# Parameters = host, username, password, database name
connection = Mysql.new 'localhost', 'test', '12345', 'wikiDatabase'
sqlStatement= connection.prepare 'INSERT INTO docRefs(docID, title, wordCount) VALUES(?,?,?)'

file = Nokogiri::XML(File.open('simplewiki-20161220-pages-meta-current.xml'))

file.css('page').each do |page|
  text = page.css('text')

  wordCount = text.to_s.split.size

  id = page.css('id')[0].text.to_s

  title = page.css('title')[0].text
  title = 'redirect' if title == nil or title == '/'

  splitTitle = title.to_s.split('/').first
  splitTitle.gsub! /\s+/,'_'

  sqlStatement.execute id, splitTitle, wordCount
end
