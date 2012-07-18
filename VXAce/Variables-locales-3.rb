# Variables locales version 1.1
# Par Grim (http://funkywork.blogspot.com)
#==============================================================================
# ** Simple_Matrix
#------------------------------------------------------------------------------
#  Manipulation de matrice facilement
#==============================================================================

class Simple_Matrix

	#--------------------------------------------------------------------------
	# * Variables d'instances
	#--------------------------------------------------------------------------
	attr_accessor :table

	#--------------------------------------------------------------------------
	# * Construction
	#--------------------------------------------------------------------------
	def initialize
		@table = []
	end

	#--------------------------------------------------------------------------
	# * Récupère une valeur
	#--------------------------------------------------------------------------
	def [](*keys)
		table, f_key = @table, keys.pop
		keys.each do |key|
			table[key] ||= []
			table = table[key]
		end
		return table[f_key]
	end

	#--------------------------------------------------------------------------
	# * Attribue une valeur
	#--------------------------------------------------------------------------
	def []=(*keys)
		value, f_key = keys.pop, keys.pop
		table = @table
		keys.each do |key|
			table[key] ||= []
			table = table[key]
		end
		table[f_key] = value
	end

end

#==============================================================================
# ** Command
#------------------------------------------------------------------------------
#  Ajoute des commandes facilement manipulables
#==============================================================================

module Command

	#--------------------------------------------------------------------------
	# * Singleton de Command
	#--------------------------------------------------------------------------
	extend self

	#--------------------------------------------------------------------------
	# * Opérandes standards
	#--------------------------------------------------------------------------
	def random(x, y) (x + rand(y - x)) end
	def map_id() $game_map.map_id end
	def var(id) $game_variables[id] end
	def set_var(id, value) 
		$game_variables[id] = value 
	end
	#--------------------------------------------------------------------------
	# * Opérandes de partie
	#--------------------------------------------------------------------------
	def team_size() $game_party.members.size end
	def gold() $game_party.gold end
	def steps() $game_party.steps end
	def play_time() (Graphics.frame_count / Graphics.frame_rate) end
	def timer() $game_timer.sec end
	def save_count() $game_system.save_count end
	def battle_count() $game_system.battle_count end
	#--------------------------------------------------------------------------
	# * Opérandes d'objets
	#--------------------------------------------------------------------------
	def item_count(id) $game_party.item_number($data_items[id]) end
	def weapon_count(id) $game_party.item_number($data_weapons[id]) end
	def armor_count(id) $game_party.item_number($data_armors[id]) end
	#--------------------------------------------------------------------------
	# * Opérandes d'acteurs
	#--------------------------------------------------------------------------
	def actor(id) $game_actors[id] end
	def level(id) $game_actors[id].level end
	def experience(id) $game_actors[id].exp end
	def hp(id) $game_actors[id].hp end
	def mp(id) $game_actors[id].mp end
	def max_hp(id) $game_actors[id].maxhp end
	def max_mp(id) $game_actors[id].maxmp end
	def attack(id) $game_actors[id].atk end
	def defense(id) $game_actors[id].def end
	def magic(id) $game_actors[id].mat end
	def magic_defense(id) $game_actors[id].mdf end
	def agility(id) $game_actors[id].agi end
	def lucky(id) $game_actors[id].luk end
	#--------------------------------------------------------------------------
	# * Opérandes d'events
	#--------------------------------------------------------------------------
	def event_x(id) 
		character = $game_player
		character = $game_map.events[id] unless id == 0
		character.x
	end
	def event_y(id) 
		character = $game_player
		character = $game_map.events[id] unless id == 0
		character.y
	end
	def event_direction(id) 
		character = $game_player
		character = $game_map.events[id] unless id == 0
		character.direction
	end
	def event_screen_x(id) 
		character = $game_player
		character = $game_map.events[id] unless id == 0
		character.screen_x
	end
	def event_screen_y(id) 
		character = $game_player
		character = $game_map.events[id] unless id == 0
		character.screen_y
	end
	def heroes_x() Command.event_x(0) end
	def heroes_y() Command.event_y(0) end
	def heroes_direction() Command.event_direction(0) end
	def heroes_screen_x() Command.event_screen_x(0) end
	def heroes_screen_y() Command.event_screen_y(0) end
	def distance_between_case(ev1, ev2)
		event1 = (ev1 == 0) ? $game_player : $game_map.events[ev1]
		event2 = (ev2 == 0) ? $game_player : $game_map.events[ev2]
		Math.hypot((event1.x - event2.x), (event1.y-event2.y))
	end
	def distance_between_pixel(ev1, ev2)
		event1 = (ev1 == 0) ? $game_player : $game_map.events[ev1]
		event2 = (ev2 == 0) ? $game_player : $game_map.events[ev2]
		Math.hypot((event1.screen_x - event2.screen_x), (event1.screen_y-event2.screen_y))
	end
	#--------------------------------------------------------------------------
	# * Opérandes de partie
	#--------------------------------------------------------------------------
	def actor_id(position) 
		$game_party.members[position]
		return actor ? actor.id : 0
	end
	#--------------------------------------------------------------------------
	# * Commande de lecture de la base de données
	#--------------------------------------------------------------------------
	def read_data_monster(id, method = false)
		monster = $data_enemies[id]
		return monster unless method
		method = method.to_sym
		value = false
		value = 0 if method == :mhp || method == :hp
		value = 1 if method == :mmp || method == :mp
		value = 2 if method == :atk || method == :attack
		value = 3 if method == :def || method == :defense
		value = 4 if method == :mat || method == :magic_attack
		value = 5 if method == :mdf || method == :magic_defense
		value = 6 if method == :agi || method == :agility
		value = 7 if method == :luk || method == :lucky
		return monster.params[value] if value
		monster.send(method)
	end
	def read_data_skill(id, method = false)
		skill = $data_skills[id]
		return skill unless method
		skill.send(method.to_sym)
	end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  Ajout du support des variables locales
#==============================================================================

class Game_Interpreter

	#--------------------------------------------------------------------------
	# * Récupération d'une variable local
	#--------------------------------------------------------------------------
	def get(*arguments)
		result = 0
		case arguments.length
		when 1; result = $game_selfVars[@map_id, @event_id, arguments[0]]
		when 2; result = $game_selfVars[@map_id, arguments[0], arguments[1]]
		when 3; result = $game_selfVars[arguments[0], arguments[1], arguments[2]]
		end
		return (result) ? result : 0
	end

	#--------------------------------------------------------------------------
	# * Attribution d'une variable locale
	#--------------------------------------------------------------------------
	def set(*arguments)
		case arguments.length
		when 2; $game_selfVars[@map_id, @event_id, arguments[0]] = arguments[1]
		when 3; $game_selfVars[@map_id, arguments[0], arguments[1]] = arguments[2]
		when 4; $game_selfVars[arguments[0], arguments[1], arguments[2]] = arguments[3]
		end
	end

	#--------------------------------------------------------------------------
	# * API de manipulation des commandes
	#--------------------------------------------------------------------------
	def cmd(command, *arguments) Command.send(command.to_sym, *arguments) end
	def command(command, *arguments) cmd(command, *arguments) end

	#--------------------------------------------------------------------------
	# * API de récupérations des monstres/acteurs/techniques
	#--------------------------------------------------------------------------
	def ennemy(id) cmd(:read_data_monster, id) end
	def actor(id) cmd(:actor, id) end
	def skill(id) cmd(:read_data_skill, id) end

end

#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
#  Ajout des variables locales
#==============================================================================

module DataManager

	class << self
		#--------------------------------------------------------------------------
		# * Alias
		#--------------------------------------------------------------------------
		alias local_create_game_objects create_game_objects
		alias local_make_save_contents make_save_contents
		alias local_extract_save_contents extract_save_contents

		#--------------------------------------------------------------------------
		# * Crée les objets du jeu
		#--------------------------------------------------------------------------
		def create_game_objects
			local_create_game_objects
			$game_selfVars = Simple_Matrix.new
		end

		#--------------------------------------------------------------------------
		# * Sauve le contenu du jeu
		#--------------------------------------------------------------------------
		def make_save_contents
			contents = local_make_save_contents
			contents[:self_vars] = $game_selfVars
			contents
		end

		#--------------------------------------------------------------------------
		# * Charge le contenu du jeu
		#--------------------------------------------------------------------------
		def extract_save_contents(contents)
			local_extract_save_contents
			$game_selfVars = contents[:self_vars]
		end

	end

end