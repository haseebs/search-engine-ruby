module Hits
  class << self
    #hit = 0b0000000000000000                        #16 bits
    CAP_MASK = 0b1000000000000000                    #1st bit only
    IMP_MASK = 0b0110000000000000                    #2nd and 3rd bit
    POS_MASK = 0b0001111111111111                    #4th to 16th

    #Anchor hits dont need to be handled because in simple wikipedia, anchor
    #text for internal links is always the title of the document it is pointing to

    #cap = Capitalization = 0 or 1
    #imp = Importance = 0 for normal, 1 for bold, 2 for fancy ( title )
    #pos = position < 8192
    def newHit(cap, imp, pos)
      pos= 8191 if pos > 8191
      newHit = 0b0000000000000000 | cap << 15 | imp << 13 | pos
    end

    #Will return 3 values
    def extractHit(hit)
      cap = (hit & CAP_MASK) >> 15
      imp = (hit & IMP_MASK) >> 13
      pos = (hit & POS_MASK)
      return cap, imp, pos
    end
  end
end
