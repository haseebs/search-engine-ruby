module GenSQL
  class << self
    def generate(rows, file)
      file = File.open(file, 'a')

      #Database should already exist at this point
      file.write("USE wikiDatabase;")
      file.write("\n")
      file.write("create table if not exists forwardIndex(docID int, wordID int, nHits  smallint unsigned, hit smallint unsigned);")
      file.write("\n")
      file.write("INSERT INTO forwardIndex VALUES(0,0,0,0)")

      rows.each do |row|
        file.write(",(#{row.docID}, #{row.wordID}, #{row.nHits}, #{row.hit})")
      end
      file.write(";")
    end
  end
end
