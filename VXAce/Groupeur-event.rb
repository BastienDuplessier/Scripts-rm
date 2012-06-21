# Consolidator par S4suk3; Fabien; XHTMLBoy (et merci à Nuki et Ulis !)
# http://funkywork.blogspot.com

#==============================================================================
# ** Config_Consolidator
#------------------------------------------------------------------------------
#  Configuration du script
#==============================================================================

module Config_Consolidator

	#--------------------------------------------------------------------------
	# * Publication des méthodes
	#--------------------------------------------------------------------------
	extend self

	#--------------------------------------------------------------------------
	# * Rayon de non-perdition par défaut
	#--------------------------------------------------------------------------
	DEFAULT_LOST_ZONE = 6

	#--------------------------------------------------------------------------
	# * Décalage des menés par rapport au meneur par défaut
	#--------------------------------------------------------------------------
	DEFAULT_DECAL = 2


end


#==============================================================================
# ** Character_Utils
#------------------------------------------------------------------------------
#  Fonctions utiles
#==============================================================================

module Character_Utils

	#--------------------------------------------------------------------------
	# * Publication des méthodes
	#--------------------------------------------------------------------------
	extend self

	#--------------------------------------------------------------------------
	# * Retourne un caractère en fonction de son id
	#--------------------------------------------------------------------------
	def get(char)
		flag =  char.is_a?(Game_Character)
		char = (char == 0) ? $game_player : $game_map.events[char] unless flag
		char
	end

end

#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  Ajoutes des outils de distances (et rend public certaines données)
#==============================================================================

class Game_Character

	#--------------------------------------------------------------------------
	# * Accesseurs / Mutateurs
	#--------------------------------------------------------------------------
	attr_accessor :through, :move_speed
	attr_reader :move_succeed

	#--------------------------------------------------------------------------
	# * Donne la distance entre deux caractères
	#--------------------------------------------------------------------------
	def distance_to(char)
		char = Character_Utils.get(char)
		coeff_x = @x - char.x
		coeff_y = @y - char.y
		Math.hypot(coeff_x, coeff_y)
	end

	#--------------------------------------------------------------------------
	# * Effectue une comparaison entre deux caractères par rapport a une cible
	#--------------------------------------------------------------------------
	def compare_distance(char, goal)
		char = Character_Utils.get(char)
		goal = Character_Utils.get(goal)
		distance_a = self.distance_to(goal)
		distance_b = char.distance_to(goal)
		result = -1
		result = 1 if distance_a > distance_b
		result = 0 if distance_b == distance_a
		result
	end

end

#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  Ajoute la gestion des collisions
#==============================================================================

class Game_Event

	#--------------------------------------------------------------------------
	# * alias
	#--------------------------------------------------------------------------
	alias consolidator_update update

	#--------------------------------------------------------------------------
	# * Définis les collisions
	#--------------------------------------------------------------------------
	def collide
		temp_x = $game_player.x
		temp_y = $game_player.y
		if Input.trigger?(Input::DOWN) and @x==temp_x and @y-1==temp_y and $game_player.direction==2
			temp_through = @through
			@through=true
			$game_player.move_straight 2
			self.move_straight 8
			@through=temp_through
		end
		if Input.trigger?(Input::LEFT) and @x+1==temp_x and @y==temp_y and $game_player.direction==4
			temp_through = @through
			@through=true
			$game_player.move_straight 4
			self.move_straight 6
			@through=temp_through
		end
		if Input.trigger?(Input::RIGHT) and @x-1==temp_x and @y==temp_y and $game_player.direction==6
			temp_through = @through
			@through=true
			$game_player.move_straight 6
			self.move_straight 4
			@through=temp_through
		end
		if Input.trigger?(Input::UP) and @x==temp_x and @y+1==temp_y and $game_player.direction==8
			temp_through = @through
			@through=true
			$game_player.move_straight 8
			self.move_straight 2
			@through=temp_through
		end
	end

	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update
		flag = $game_map.groups.count{|group| group.member_exists?(@id) if group}
		collide if flag > 0
		consolidator_update
	end

	#--------------------------------------------------------------------------
	# * Vérifie si le caractère doit courrir
	#--------------------------------------------------------------------------
	def dash?
		flag = $game_map.groups.count do |group|  
			(group.member_exists?(@id) && group.leader.id == 0 && !group.missed?(@id) && group.dash?) if group 
		end
		return $game_player.dash? && flag > 0
	end

end


#==============================================================================
# ** Pawn
#------------------------------------------------------------------------------
#  Déscription d'un membre du groupe
#==============================================================================

class Pawn

	#--------------------------------------------------------------------------
	# * Méthodes propre à la classe
	#--------------------------------------------------------------------------

	class << self

		#--------------------------------------------------------------------------
		# * Retourne un index en fonction d'un type
		#--------------------------------------------------------------------------
		def emoticone(type)
			case type
			when :rage
				return 7
			when :spite
				return 6
			when :nervousness
				return 5
			when :disturbed
				return 8
			else
				return 6
			end

		end
	end

	#--------------------------------------------------------------------------
	# * Accesseurs / Mutateurs
	#--------------------------------------------------------------------------
	attr_accessor :id, :emotion, :frustration

	#--------------------------------------------------------------------------
	# * Constructeur
	#--------------------------------------------------------------------------
	def initialize(id, emotion = :default)
		@id = id
		@frustration = 0
		@emotion = emotion.to_sym
	end

	#--------------------------------------------------------------------------
	# * Retourne l'event relié au Pawn
	#--------------------------------------------------------------------------
	def event
		Character_Utils.get(@id)
	end

	#--------------------------------------------------------------------------
	# * Déplace vers un caractère
	#--------------------------------------------------------------------------
	def move_to(goal)
		event.move_toward_character(goal)
	end

	#--------------------------------------------------------------------------
	# * Tourne en direction d'un caractère
	#--------------------------------------------------------------------------
	def turn_to(goal)
		event.turn_toward_character(goal)
	end

	#--------------------------------------------------------------------------
	# * Compare 2 evenement (cf Game_Character)
	#--------------------------------------------------------------------------
	def compare_to(other, goal)
		self.event.compare_distance(other.event, goal.id)
	end

	#--------------------------------------------------------------------------
	# * Donne la vitesse d'un event
	#--------------------------------------------------------------------------
	def speed
		event.move_speed
	end

	#--------------------------------------------------------------------------
	# * Attribue la vitesse d'un event
	#--------------------------------------------------------------------------
	def speed=(ns)
		event.move_speed = ns
	end

end

#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  Ajoute des outils de manipulation des pawn
#==============================================================================

module Kernel

	#--------------------------------------------------------------------------
	# * Accès public des méthodes
	#--------------------------------------------------------------------------
	extend self

	#--------------------------------------------------------------------------
	# * Crée un Pawn avec une "émotion"
	#--------------------------------------------------------------------------
	def event(id, emotion = :default)
		Pawn.new(id, emotion)
	end

	#--------------------------------------------------------------------------
	# * Fait vibrer un caractère
	#--------------------------------------------------------------------------
	def buzz(id, amplitude = 0.1, duration = 30, periode = 30)
		if SceneManager.scene_is?(Scene_Map)
			if $game_player.respond_to?(:buzz=)
				event = Character_Utils.get(id)
				event.buzz = duration
				event.buzz_length = duration
				event.buzz_amplitude = amplitude
				return true
			end
		end
		return false
	end


end

#==============================================================================
# ** Game_Group
#------------------------------------------------------------------------------
#  Déscription d'un groupe
#==============================================================================

class Game_Group

	#--------------------------------------------------------------------------
	# * Méthodes propre à la classe
	#--------------------------------------------------------------------------
	class << self

		#--------------------------------------------------------------------------
		# * Liste des comportemments
		#--------------------------------------------------------------------------
		def behaviours
			[:normal, :ghost, :teleport, :jump]
		end

		#--------------------------------------------------------------------------
		# * Défini si un symbole est un comportemment
		#--------------------------------------------------------------------------
		def behaviour?(var)
			behaviours.include?(var.to_sym)
		end

	end

	#--------------------------------------------------------------------------
	# * Accesseurs / Mutateurs
	#--------------------------------------------------------------------------
	attr_reader :members, :id
	attr_accessor :lost_distance, :leader, :type, :decal, :dash

	#--------------------------------------------------------------------------
	# * Constructeur
	#--------------------------------------------------------------------------
	def initialize(id, lost_distance, decal, type, leader, *complement)
		@id = id
		@dash = true
		@leader = Pawn.new(leader)
		@lost_distance = lost_distance
		@decal = decal
		@type = :normal
		@type = type if Game_Group.behaviour?(type)
		@members = []
		self.add(*complement)
	end

	#--------------------------------------------------------------------------
	# * Attribue un type
	#--------------------------------------------------------------------------
	def type=(type)
		@type = type.to_sym if Game_Group.behaviour?(type)
	end

	#--------------------------------------------------------------------------
	# * Redéfini le leader
	#--------------------------------------------------------------------------
	def leader=(id)
		unless id
			@members << @leader
			@leader = nil
			return true
		end
		potential_index = @members.find{|member|member.id == id}
		unless potential_index
			@members << @leader
			@leader = Pawn.new(id)
			return true
		end
		if potential_index
			@members << @leader
			@leader = @members[potential_index]
			@members[potential_index] = nil
			@members.compact!
			return true
		end
		return false
	end

	#--------------------------------------------------------------------------
	# * Retourne un membre en fonction de son ID
	#--------------------------------------------------------------------------
	def member(id)
		@members.find{|member| member.id == id}
	end

	#--------------------------------------------------------------------------
	# * Ajoute des membres
	#--------------------------------------------------------------------------
	def add(*members)
		members.each do |member|
			$game_map.groups.each do |group|
				if group
					if group.id != @id
						group.remove(member) if group.member_exists?(member)
					end
				end
			end
			to_add = (member.is_a?(Pawn)) ? member : Pawn.new(member)
			to_add.speed = @leader.speed
			find = @members.find{|elt| elt.id == to_add.id} if @members
			@members << to_add unless find
		end
	end

	#--------------------------------------------------------------------------
	# * Retire des membres
	#--------------------------------------------------------------------------
	def remove(*members)
		members.each do |member|
			index = @members.index{|elt| elt.id == member}
			@members.delete_at(index)
		end
		@members.compact!
	end

	#--------------------------------------------------------------------------
	# * Nettoie le groupe
	#--------------------------------------------------------------------------
	def clear
		@members = []
	end
	
	#--------------------------------------------------------------------------
	# * Détruit un groupe
	#--------------------------------------------------------------------------
	def delete
		$game_map.groups.delete_at(@id)
	end

	#--------------------------------------------------------------------------
	# * Fonction utilitaire : Retourne le personnage le plus proche du meneur
	#   avant le membre ID
	#--------------------------------------------------------------------------
	def prec(id)
		return @leader.event if id == 0
		@members[id-1].event
	end

	#--------------------------------------------------------------------------
	# * Exécute les déplacements
	#--------------------------------------------------------------------------
	def update
		return nil unless @leader
		@members.sort!{|e1, e2| e1.compare_to(e2, @leader) }
		@members.compact!
		@members.each do |member|
			index = @members.index(member) 
			fl = (@type == :ghost && member.event.distance_to(self.prec(index)) > @lost_distance)
			ll =  !$game_map.passable?(member.event.x, member.event.y, member.event.direction)
			member.event.through =  fl || ll
			if (@type == :teleport || @type == :jump) &&  member.event.distance_to(@leader.id) > @lost_distance + @members.length
				if @type == :teleport
					member.event.moveto(@leader.event.x, @leader.event.y) 
				else
					route = RPG::MoveRoute.new()
					x = (@leader.event.x - member.event.x)
					y = (@leader.event.y - member.event.y)
					route.list = [RPG::MoveCommand.new(14,[x, y])]
					route.wait = true
					member.event.force_move_route(route)
				end
				member.event.turn_toward_character(@leader.event)
			end
			if !member.event.moving? and (member.event.distance_to(self.prec(index))) > @decal
				member.move_to(@leader.event)
				member.move_to(self.prec(index)) unless member.event.move_succeed
			else
				if member.emotion == :nervousness
					ra = Kernel.rand(2)
					if ra == 1 && !member.event.moving? && member.event.distance_to(@leader.event) > 1
						member.move_to(@leader.event)
						member.move_to(self.prec(index)) unless member.event.move_succeed
					end
				end
			end
			if member.event.distance_to(@leader.event) >= @lost_distance+(@members.length)
				rb = Kernel.rand(100)
				 if rb >= 95 && member.emotion != :none
					member.event.balloon_id = Pawn.emoticone(member.emotion)
					member.frustration += 1
				end
				buzz(member.id) if rb >= 90 && member.emotion != :nervousness
				if member.emotion == :nervousness && rb > 90
					route = RPG::MoveRoute.new()
					route.list = [RPG::MoveCommand.new(14,[0, 0])]
					route.wait = true
					member.event.force_move_route(route)
					member.speed = @leader.speed
				end
			end
		end
	end

	#--------------------------------------------------------------------------
	# * Vérifie si un membre existe dans le groupe
	#--------------------------------------------------------------------------
	def member_exists?(id)
		return 0 unless @members
		@members.count{|member| member.id == id} > 0 || @leader.id == id
	end

	#--------------------------------------------------------------------------
	# * Vérifie si un membre est perdu
	#--------------------------------------------------------------------------
	def missed?(id)
		member(id).event.distance_to(@leader.event) >= @lost_distance+(@members.length)
	end

	#--------------------------------------------------------------------------
	# * Calcul le nombre de membres manquants 
	#--------------------------------------------------------------------------
	def miss_people
		total = @members.count do |member|
			missed?(member.id)
		end
		total
	end

	#--------------------------------------------------------------------------
	# * Vérifie si le groupe est complet
	#--------------------------------------------------------------------------
	def complete?
		miss_people == 0
	end

	#--------------------------------------------------------------------------
	# * Vérifie si le groupe peut courrir
	#--------------------------------------------------------------------------
	def dash?
		@dash
	end

end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  Ajoute la gestion des groupes
#==============================================================================

class Game_Map

	#--------------------------------------------------------------------------
	# * alias
	#--------------------------------------------------------------------------
	alias consolidator_setup setup
	alias consolidator_update update

	#--------------------------------------------------------------------------
	# * Accesseurs / Mutateurs
	#--------------------------------------------------------------------------
	attr_accessor :groups

	#--------------------------------------------------------------------------
	# * Initialisation de la carte
	#--------------------------------------------------------------------------
	def setup(map_id)
		@groups = []
		consolidator_setup(map_id)
	end

	#--------------------------------------------------------------------------
	# * Mise à jours de la carte
	#--------------------------------------------------------------------------
	def update(main = false)
		@groups.each do |group|
			group.update if group
		end
		consolidator_update(main)
	end

	#--------------------------------------------------------------------------
	# * Récupère un groupe
	#--------------------------------------------------------------------------
	def group(id)
		return @groups[id]
	end

	#--------------------------------------------------------------------------
	# * Ajoute un groupe
	#--------------------------------------------------------------------------
	def add_group(id, lose, decal, type, leader, *members)
		@groups[id] = Game_Group.new(id, lose, decal, type, leader, *members)
	end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  Ajoute les fonctionnalités des groupes
#==============================================================================

class Game_Interpreter

	#--------------------------------------------------------------------------
	# * Crée un groupe
	# id = identifiant du groupe
	# lose = Distance max avant qu'un event soit perdu
	# decal = Le décalage positionnel des membres
	# leader = Id du leader
	# *members = liste des membres
	#--------------------------------------------------------------------------
	def create_group(id, lose, decal, type, leader, *members)
		$game_map.add_group(id, lose, decal, type, leader, *members)
	end

	#--------------------------------------------------------------------------
	# * Crée un groupe simplement avec des paramètres par défaut
	# id = identifiant du groupe
	# leader = Id du leader
	# *members = liste des membres
	#--------------------------------------------------------------------------
	def create_simple_group(id, leader, *members)
		$game_map.add_group(id, Config_Consolidator::DEFAULT_LOST_ZONE, Config_Consolidator::DEFAULT_DECAL,:normal, leader, *members)
	end

	#--------------------------------------------------------------------------
	# * Recupère un groupe (pour lui appliquer des transformations)
	#--------------------------------------------------------------------------
	def group(id)
		return $game_map.group(id)
	end

end