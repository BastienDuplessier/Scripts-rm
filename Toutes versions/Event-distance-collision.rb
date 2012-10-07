# Utilitaire pour Loly74, par RAHO
# Explication
#==============================================================================
# Ce script est un petit utilitaire pour agrémenter l'utilisation des Events !
# Il est décomposé en 3 petites commandes.

# La première:
# -----------------------------------------------------------------------------
# x.collision_avec? y
# Détermine si x est en collision avec y (en collision = juste a coté et regardant dans la direction de y)
# Il est préférable, en event making de l'appeller dans "Condition > Script"

# La seconde
# -----------------------------------------------------------------------------
# x.distance_de y
# Donne la distance (en case à vol d'oiseau) entre 2 évènements.

# La troisième
# -----------------------------------------------------------------------------
# x.donne_valeur y
# Attribue y comme valeur à la variable (eventmaking) x.

# Note
# -----------------------------------------------------------------------------
# les variable x, y correspondent aux numéros d'ID des events
# Sauf dans le cas de donne_valeur où x correspond au numéro de la variable et 
# y à la valeur à lui donner
# L'id du Héro est toujours 0

# Exemples
# -----------------------------------------------------------------------------
# 55.donne_valeur (12.distance_de 0)
# Cet appel de script donnera la distance en case entre l'event 12 et le héros à la variable 55

#==============================================================================
# ** UtilEvents
#------------------------------------------------------------------------------
#  Utilitaire de comparaisons d'events
#==============================================================================

module UtilEvents
	extend self
	#--------------------------------------------------------------------------
	# * Retourne facilement un event
	#--------------------------------------------------------------------------
	def event(id)
		return $game_player if id == 0
		return $game_map.events[id]
	end
	#--------------------------------------------------------------------------
	# * Vérifie si 2 events sont en collisions
	#--------------------------------------------------------------------------
	def collision(ev1, ev2)
		event1 = UtilEvents.event(ev1)
		event2 = UtilEvents.event(ev2)
		direction = event1.direction
		return true if event2.x == event1.x && event2.y == event1.y+1 && direction == 2
		return true if event2.x == event1.x-1 && event2.y == event1.y && direction == 4
		return true if event2.x == event1.x+1 && event2.y == event1.y && direction == 6
		return true if event2.x == event1.x && event2.y == event1.y-1 && direction == 8
		return false
	end
	#--------------------------------------------------------------------------
	# * Retourne la distance entre 2 events
	#--------------------------------------------------------------------------
	def distance(ev1, ev2)
		hypot_a = UtilEvents.event(ev1).x - UtilEvents.event(ev2).x
		hypot_b = UtilEvents.event(ev1).y - UtilEvents.event(ev2).y
		return Math.hypot(hypot_a, hypot_b)
	end
end

#==============================================================================
# ** Fixnum
#------------------------------------------------------------------------------
#  API pour l'utilitaire d'évènement
#==============================================================================

class Fixnum
	#--------------------------------------------------------------------------
	# * Vérifie si 2 evenements sont en collisions?
	#--------------------------------------------------------------------------
	def collision_avec?(autre)
		return UtilEvents.collision(self, autre)
	end
	#--------------------------------------------------------------------------
	# * Donne la distance entre 2 evenements
	#--------------------------------------------------------------------------
	def distance_de(autre)
		return UtilEvents.distance(self, autre)
	end
	#--------------------------------------------------------------------------
	# * Donne la valeur a une variable
	#--------------------------------------------------------------------------
	def donner_valeur(valeur)
		$game_variables[self] = valeur.to_i
	end
end