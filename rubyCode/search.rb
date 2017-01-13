require 'mysql'
require './singleWordSearch.rb'
require './multiWordSearch.rb'

class Search

  BLACKLIST = ['a', 'an', 'the', 'at','by','down','for','from','in','of','off','on','out','to','up','upon','you']

  def query(word)
    words = word.chomp.downcase.split
    words -= BLACKLIST
    return nil if words.count == 0
    return SingleWordSearch.search(words) if words.count == 1
    return MultiWordSearch.search(words) if words.count > 1
  end
end

