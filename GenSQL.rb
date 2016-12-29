module GenSQL
  class << self
    def generate(rows, filePath)
      file = File.open(filePath, 'a+')
      text = file.read

      #Database should already exist at this point
      text << "INSERT IGNORE INTO forwardIndex VALUES(0,0,0,0)"

      count = 0
      rows.each do |row|
        count += 1
        text << ",(#{row.docID}, #{row.wordID}, #{row.nHits}, #{row.hit})"
      end
      text << ";" if count > 0
      file = File.open(filePath, 'w')

      file.write text
    end
  end
end

