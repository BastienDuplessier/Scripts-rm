# Ajoute les commandes de message (\V[x], \N[x], \P[x], \G) dans les noms 
# de techniques
#==============================================================================
# ** RPG::Skill
#------------------------------------------------------------------------------
# The data class for skills.
#==============================================================================

class RPG::Skill
  #--------------------------------------------------------------------------
  # * get Name
  #--------------------------------------------------------------------------
  def name
    result = @name.to_s.clone
    result.gsub!(/\\/){ "\e" }
    result.gsub!(/\e\e/){ "\\" }
    result.gsub!(/\eV\[(\d+)\]/i){ $game_variables[$1.to_i] }
    result.gsub!(/\eN\[(\d+)\]/i){ actor_name($1.to_i) }
    result.gsub!(/\eP\[(\d+)\]/i){ party_member_name($1.to_i) }
    result.gsub!(/\eG/i){ Vocab::currency_unit }
    result
  end
end