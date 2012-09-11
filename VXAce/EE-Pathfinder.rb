# Module Pathfinder par Grim (inspiré par Avygeil EL3.0)
# Détail des commandes
# cmd(:move_to, ID_EVENT, X, Y)
#==============================================================================
# ** Pathfinder
#------------------------------------------------------------------------------
#  Module to manage pathfinder
#==============================================================================

module Pathfinder
	#--------------------------------------------------------------------------
	# * Constants
	#--------------------------------------------------------------------------
	Goal = Struct.new(:x, :y)
	ROUTE_MOVE_DOWN = 1
	ROUTE_MOVE_LEFT = 2
	ROUTE_MOVE_RIGHT = 3
	ROUTE_MOVE_UP = 4
	#--------------------------------------------------------------------------
	# * Definition of a point
	#--------------------------------------------------------------------------
	class Point
		#--------------------------------------------------------------------------
		# * Public Instance Variables
		#--------------------------------------------------------------------------
		attr_accessor :x, :y, :g, :h, :f, :parent, :goal
		#--------------------------------------------------------------------------
		# * Object initialize
		#--------------------------------------------------------------------------
		def initialize(x, y, p, goal = Goal.new(0,0))
			@goal = goal
			@x, @y, @parent = x, y, p
			self.score(@parent)
		end
		#--------------------------------------------------------------------------
		# * id
		#--------------------------------------------------------------------------
		def id
			return "#{@x}-#{@y}"
		end
		#--------------------------------------------------------------------------
		# * Calculate score
		#--------------------------------------------------------------------------
		def score(parent)
			if !parent
				@g = 0
			elsif !@g || @g > parent.g + 1
				@g = parent.g + 1
				@parent = parent
			end
			@h = (@x - @goal.x).abs + (@y - @goal.y).abs
			@f = @g + @h
		end
		#--------------------------------------------------------------------------
		# * Cast to move_command
		#--------------------------------------------------------------------------
		def to_move
			return nil unless @parent
			return RPG::MoveCommand.new(2) if @x < @parent.x
			return RPG::MoveCommand.new(3) if @x > @parent.x
			return RPG::MoveCommand.new(4) if @y < @parent.y
			return RPG::MoveCommand.new(1) if @y > @parent.y
			return nil
		end
	end
	#--------------------------------------------------------------------------
	# * Singleton of Pathfinder
	#--------------------------------------------------------------------------
	class << self
		#--------------------------------------------------------------------------
		# * spec ID
		#--------------------------------------------------------------------------
		def id(x, y)
			return "#{x}-#{y}"
		end
		#--------------------------------------------------------------------------
		# * Create a path
		#--------------------------------------------------------------------------
		def create_path(goal, event)
			open_list = {}
			closed_list = {}
			current = Point.new(event.x, event.y, nil, goal)
			open_list[current.id] = current
			while !closed_list.has_key?(id(goal.x, goal.y)) && !open_list.empty?
				current = open_list.values.min{|point1, point2|point1.f <=> point2.f}
				open_list.delete(current.id)
				closed_list[current.id] = current
				if $game_map.passable?(current.x, current.y, 2) && !closed_list.has_key?(id(current.x, current.y+1))
					if !open_list.has_key?(id(current.x, current.y+1))
						open_list[id(current.x, current.y+1)] = Point.new(current.x, current.y+1, current, goal)
					else
						open_list[id(current.x, current.y+1)].score(current)
					end
				end
				if $game_map.passable?(current.x, current.y, 4) && !closed_list.has_key?(id(current.x-1, current.y))
					if !open_list.has_key?(id(current.x-1, current.y))
						open_list[id(current.x-1, current.y)] = Point.new(current.x-1, current.y, current, goal)
					else
						open_list[id(current.x-1, current.y)].score(current)
					end
				end
				if $game_map.passable?(current.x, current.y, 4) && !closed_list.has_key?(id(current.x+1, current.y))
					if !open_list.has_key?(id(current.x+1, current.y))
						open_list[id(current.x+1, current.y)] = Point.new(current.x+1, current.y, current, goal)
					else
						open_list[id(current.x+1, current.y)].score(current)
					end
				end
				if $game_map.passable?(current.x, current.y, 2) && !closed_list.has_key?(id(current.x, current.y-1))
					if !open_list.has_key?(id(current.x, current.y-1))
						open_list[id(current.x, current.y-1)] = Point.new(current.x, current.y-1, current, goal)
					else
						open_list[id(current.x, current.y-1)].score(current)
					end
				end
			end
			move_route = RPG::MoveRoute.new
			if closed_list.has_key?(id(goal.x, goal.y))
				current = closed_list[id(goal.x, goal.y)]
				while current 
					move_command = current.to_move
					move_route.list = [move_command] + move_route.list if move_command
					current = current.parent
				end
			end
			move_route.list.pop
			return move_route
		end
	end
end

#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  This base class handles characters. It retains basic information, such as 
# coordinates and graphics, shared by all characters.
#==============================================================================

class Game_Character
	#--------------------------------------------------------------------------
	# * Move to x y coord
	#--------------------------------------------------------------------------
	def move_to_position(x, y)
		return if not $game_map.passable?(x,y,0)
		route = Pathfinder.create_path(Pathfinder::Goal.new(x, y), self)
		self.force_move_route(route)
	end
end

#==============================================================================
# ** Command
#------------------------------------------------------------------------------
#  Ajoute des commandes facilement manipulables (Event Extender)
#==============================================================================

module Command
	#--------------------------------------------------------------------------
	# * Singleton de Command
	#--------------------------------------------------------------------------
	extend self
	#--------------------------------------------------------------------------
	# * Move event to a point (if the point 's passable)
	# id = id of the event
	#--------------------------------------------------------------------------
	def move_to(id, x, y)
		$game_map.events[id].move_to_position(x, y)
	end
end