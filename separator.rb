#Splits the given  XML document based on
#page tags and names them as the underlying id tag

require 'nokogiri'

file = Nokogiri::XML(File.open('simplewiki-20161220-pages-meta-current.xml'))

file.css('page').each do |page|
  newFile = File.open(page.css('id')[0], 'w')
  newFile.puts page
end
