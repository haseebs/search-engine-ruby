

file=Dir.glob("C:/Users/Abdul Qadir/ruby/folder/**/*")     # file names in subfolder of current folder

file.each do |f|
  newWord1=f.gsub( "C:/Users/Abdul Qadir/ruby/folder/",'')
  newWord2=newWord1.gsub("-"," ")
  newWord3=newWord2.gsub("_"," ")             #removing '_' and '-' from titles and inserting space in their place
  newWord=newWord3.gsub(/\d+/, "").squeeze(" ").strip #removing digits froms titles ie doc id and no fo words
  puts newWord
end
