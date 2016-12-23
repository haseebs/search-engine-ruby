#this function reads xml file and count number of words.

require 'nokogiri'
doc = Nokogiri::XML(File.open("asd.xml"))
doc.xpath('//text').each do |char_element|
puts char_element.to_s.split.size

end
