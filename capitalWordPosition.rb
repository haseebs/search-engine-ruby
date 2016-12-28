require 'nokogiri'
count=0
b=""
file = Nokogiri::XML(File.open('asd.xml'))

file.css('text').each do |page|
  b = page.text.to_s.split(/[\s,\W]/).select{|_w| _w =~ /^\w+$/}
end

  b.each do |a|
  count+=1                                        #counting total number of words
  puts "#{b.index(a)}: #{a}"                     #displaying each word and its position


  if a == a.upcase && a =~ /[A-Za-z]/          #uppercase words
        puts  "***UPPERCASE WORD: #{a}   "
    end

  end


puts  "***Total number of words #{count} ";                                    #total number of words
