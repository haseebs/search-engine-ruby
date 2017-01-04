module GenSQL
  class << self

    #Function for forward Index sql file generation
    #Takes row data and file path as parameters
    def generate(rows, filePath)
      file = File.open(filePath, 'a+')
      #Database should already exist at this point
      file << "INSERT IGNORE INTO forwardIndex VALUES(0,0,0,0)"
      rows.each do |row|
        file << ",(#{row.docID}, #{row.wordID}, #{row.nHits}, #{row.hit})"
      end
      file.write(";")
      file.close
    end

    #Function for inverted Index sql file generation
    #Takes row data and file path as parameters
    def generateInverted(rows, filepath)
      file = File.open(filepath, 'w')
      #Database should already exist at this point
      file.write("INSERT IGNORE INTO invertedIndex VALUES(0,0,0,0,0)")
      rows.each do |row|
        file.write(",(#{row.wordID}, #{row.nDocs}, #{row.docID}, #{row.nHits}, #{row.hit})")
      end
      file.write(";")
      file.close
    end
  end
end

