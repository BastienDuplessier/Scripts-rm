#==============================================================================
# Ajoute un déclencheur personnalisé pour les évènements ! 
# Il suffit que la première ligne de la page soit un commentaire qui contient :
# Trigger : votre condition
# Par exemple, si on veut que l'évènement ne se déclenche que si la variable 
# locale 3 de l'évènement 1 est à 8 :
# Trigger : get(1, 3) == 8

# Il est possible de coupler les conditions par exemple:
# Trigger : get(1, 3) == 8 and get(1, 4) > 10
# Trigger : (get(1, 3) == 8 or get(1, 4) >= 12) and V[10] == 7

# Opérateurs logiques => and (et) or (ou)
# opérateurs arithmétiques:
# x > y (x est plus grand strictement que y)
# x < y (y est plus grand strictement que x)
# x <= y (y est plus grand ou égal que x)
# x >= y (x est plus grand ou égal que y)
# x == y (x est égal à y)
# x != y (x est différent à y)

# Par Grim, merci à Siegfried !
#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class handles events. Functions include event page switching via
# condition determinants and running parallel process events. Used within the
# Game_Map class.
#==============================================================================

class Game_Event 
	attr_accessor :event
	#--------------------------------------------------------------------------
	# * Alias
	#--------------------------------------------------------------------------
	alias ee_conditions_met? conditions_met?
	#--------------------------------------------------------------------------
	# * Determine if Event Page Conditions Are Met
	#--------------------------------------------------------------------------
	def conditions_met?(page)
		value = ee_conditions_met?(page)
		first = first_is_comment?(page)
		return value unless first
		condition_comment = true
		if first =~ /^Trigger\s*:\s*(.+)/
			trigger_data = $~[1]
			condition_comment = self.send(:eval, trigger_data)
		end
		return value && condition_comment
	end
	#--------------------------------------------------------------------------
	# * Determine if the first command is a Comment
	#--------------------------------------------------------------------------
	def first_is_comment?(page)
		return false unless page || page.list || page.list[0]
		return false unless page.list[0].code == 108
		index = 1
		list = [page.list[0].parameters[0]]
		while page.list[index].code == 408
			list << page.list[index].parameters[0]
			index += 1
		end
		return list.collect{|line|line+=" "}.join
	end
	#--------------------------------------------------------------------------
	# * GET Variable Locale API
	#--------------------------------------------------------------------------
	def get(*arguments)
		case arguments.length
		when 1; result = $game_selfVars[@map_id, @id, arguments[0]]
		when 2; result = $game_selfVars[@map_id, arguments[0], arguments[1]]
		when 3; result = $game_selfVars[arguments[0], arguments[1], arguments[2]]
		end
		result ||= 0
		return result
	end
end