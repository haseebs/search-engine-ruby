require 'enumerator'

module MultiWordHelper
  #separated by [0,1,2,3,4,5,5+]
  PROXIMITY_WEIGHT = [20,15,10,5,3,1,0]
  #[title, capitalization, bold, plain]
  TYPE_WEIGHT = [200, 10, 8, 1]


  class << self

    def cartesian(vectors)
      cart = vectors[0]
      vectors.each_with_index do |vector, index|
        next if index == 0
        cart = cart.product vector
      end
      cart.flatten!
    end

    def proximityWeight(vector)
      pw = []
      vector.each do |vec|
        if PROXIMITY_WEIGHT[vec].nil? then pw << 0 else pw << PROXIMITY_WEIGHT[vec] end
      end
      #print pw
    end

    def proximity(vectors)
      cart = cartesian(vectors)
      numWords = vectors.count
      result = []
      cart.each_slice(numWords) do |pair|
        r = []
        pair.each_cons(2) do |pr|
          if pr[1]==pr[0] and pr[1]==8191 then r << 10 else r << (pr[1]-pr[0]).abs end
        end
        result << r.reduce(:+) / r.size
      end
      proximityWeight(result)
    end

    def typeWeight(vectors)
      cart = cartesian(vectors)
      numWords = vectors.count
      result = []
      cart.each_slice(numWords) do |pair|
        result << pair.reduce(:+)
      end
      result
    end

    def type(cap, imp)
      if cap == 1
        TYPE_WEIGHT[1]
      else
        case imp
        when 0
          TYPE_WEIGHT[3]
        when 1
          TYPE_WEIGHT[2]
        when 2
          TYPE_WEIGHT[0]
        end
      end
    end

  end
end


#MultiWordHelper.proximity([[365, 8191], [367, 793, 1432, 1439, 1448, 1456, 1565, 3585, 4891, 5451, 5459, 6099, 7062, 7290, 7500, 7672, 7831, 8011, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191,8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191,8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191, 8191]] )
#print MultiWordHelper.typeWeight(0,1)
