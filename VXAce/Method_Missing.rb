#==============================================================================
# ** String
#------------------------------------------------------------------------------
#  A String object holds and manipulates an arbitrary sequence of bytes, 
#  typically representing characters.
#==============================================================================

class String
  #--------------------------------------------------------------------------
  # * Calcul the Damerau Levenshtein 's Distance 
  #--------------------------------------------------------------------------
  def damerau_levenshtein(other)
    n, m = self.length, other.length
    return m if n == 0
    return n if m == 0
    matrix  = Array.new(n+1) do |i|
      Array.new(m+1) do |j|
        if i == 0 then j
        elsif j == 0 then i 
        else 0 end
      end
    end
    (1..n).each do |i|
      (1..m).each do |j|
        cost = (self[i] == other[j]) ? 0 : 1
        delete = matrix[i-1][j] + 1
        insert = matrix[i][j-1] + 1
        substitution = matrix[i-1][j-1] + cost
        matrix[i][j] = [delete, insert, substitution].min
        if (i > 1) && (j > 1) && (self[i] == other[j-1]) and (self[i-1] == other[j])
          matrix[i][j] = [matrix[i][j], matrix[i-2][j-2] + cost].min
        end
      end
    end
    return matrix.last.last
  end
end

#==============================================================================
# ** Object
#------------------------------------------------------------------------------
#  Generic behaviour
#==============================================================================

class Object
  #--------------------------------------------------------------------------
  # * Method suggestions
  #--------------------------------------------------------------------------
  def method_missing(*args)
    keywords = self.methods + self.singleton_methods + self.class.instance_methods(false)
    keywords += self.instance_variables
    keywords.uniq!.collect!{|i|i.to_s}
    keywords.sort_by!{|o| o.damerau_levenshtein(args[0].to_s)}
    msg = "#{args[0]} doesn't exists did you mean maybe #{keywords[0]} or #{keywords[1]}  ?"
    raise(NoMethodError, msg)
  end
end