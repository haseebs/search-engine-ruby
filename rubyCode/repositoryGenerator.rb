#Splits the given  XML document based on
#page tags and names them as the underlying id tag + title + wordCount

#including the ruby library nokogiri to manipulate xml fiel
require 'nokogiri'

#opening the given simple wikipedia xml file
file = Nokogiri::XML(File.open(File.expand_path("..", Dir.pwd) + '/simplewiki-20161220-pages-meta-current.xml'))

#in the given xml file pages are separated by <page> </page> tags
#converting each page to a file to generate repository
#each page has already been assigned a pageid 'id'
#name of every file starts with pageId then title and ends with number of words 
#since file name can't contain slashes so we insert '_' in their place
# file name 'id-title-no_of _words'

file.css('page').each do |page|
  wordCount = 0

  #reading text from everypage between <text> </text> tags
  text = page.css('text')

  #counting number of words in a file 
  wordCount = text.to_s.split.size

  #in the file name pageId/ docId is separated from title by "-"
  filename = page.css('id')[0].text.to_s
  filename << '-'

  title = page.css('title')[0].text
  title = 'redirect' if title == nil or title == '/'

  #removing '/' from title and inserting '_' at their plce
  filename.concat title.to_s.split('/').first
  filename.gsub! /\s+/, '_'

  #number of words are concatenatted to the by file name separarated by '-'
  filename << '-'
  filename.concat wordCount.to_s
  next if filename == nil

  File.open(File.expand_path("..", Dir.pwd) + '/repository/'+filename, 'w').puts(text)
end
