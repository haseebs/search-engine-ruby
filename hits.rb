module Hits
  class << self
    #hit = 0b0000000000000000                        #16 bits
    CAP_MASK = 0b1000000000000000                    #1st bit only
    IMP_MASK = 0b0110000000000000                    #2nd and 3rd bit
    FANCY_MASK = 0b0001100000000000                  #4th and 5th bitt, can be title, anchor or meta
    FANCY_POS_MASK = 0b0000011111111111              #FANCY_POS_MASK6th to 16th
    ANCHOR_HASH_MASK = 0b0000011110000000            #6th to 9th
    ANCHOR_POS_MASK = 0b0000000001111111             #10th to 16th
    PLAIN_POS_MASK = 0b0001111111111111              #4th to 16th

    #cap = Capitalization = 0 or 1
    #imp = Importance = 0 for normal, 1 for bold, 2 for fancy ( title )
    #pos = position < 8192
    def newHit(cap, imp, pos)
      pos= 8191 if pos > 8191
      newHit = 0b0000000000000000 | cap << 15 | imp << 13 | pos
    end

    def extractHit(hit)
      cap = (hit & CAP_MASK) >> 15
      imp = (hit & IMP_MASK) >> 13
      pos = (hit & PLAIN_POS_MASK)
      puts cap.to_s + ' ' + imp.to_s  + ' ' + pos.to_s
    end
  end
end
