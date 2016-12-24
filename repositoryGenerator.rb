#Splits the given  XML document based on
#page tags and names them as the underlying id tag + title + wordCount

require 'nokogiri'

file = Nokogiri::XML(File.open('simplewiki-20161220-pages-meta-current.xml'))

file.css('page').each do |page|
  wordCount = 0
  text = page.css('text')
  wordCount = text.to_s.split.size

  filename = page.css('id')[0].text.to_s
  filename << '-'

  title = page.css('title')[0].text
  title = 'redirect' if title == nil or title == '/'

  filename.concat title.to_s.split('/').first
  filename.gsub! /\s+/, '_'

  filename << '-'
  filename.concat wordCount.to_s
  next if filename == nil

  File.open(filename, 'w').puts(text)
end
