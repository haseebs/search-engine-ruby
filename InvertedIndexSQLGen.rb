module InvertedIndexSQLGen
  class << self
    def generate(rows, file)
      file = File.open(file, 'w')

      #Database should already exist at this point
      file.write("INSERT INTO invertedIndex VALUES(0,0,0,0,0)")
      rows.each do |row|
        file.write(",(#{row.wordID}, #{row.nDocs}, #{row.docID}, #{row.nHits}, #{row.hit})")
      end
      file.write(";")
      file.close
    end
  end
end
