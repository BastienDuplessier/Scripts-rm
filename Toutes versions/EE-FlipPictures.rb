#==============================================================================
# ** Picture Flip
#------------------------------------------------------------------------------
#  Can Apply a horizontal flip to a pictures.
#  Script Call : cmd(:picture_flip, ID_PICTURE)
#==============================================================================

#==============================================================================
# ** Game_Picture
#------------------------------------------------------------------------------
#  This class handles pictures. It is created only when a picture of a specific
# number is required internally for the Game_Pictures class.
#==============================================================================

class Game_Picture
	#--------------------------------------------------------------------------
	# * Alias
	#--------------------------------------------------------------------------
	alias pictures_ee_initialize initialize
	#--------------------------------------------------------------------------
	# * Public Instance Variables
	#--------------------------------------------------------------------------
	attr_accessor :mirror
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(number)
		pictures_ee_initialize(number)
		@mirror = false
	end
end

#==============================================================================
# ** Sprite_Picture
#------------------------------------------------------------------------------
#  This sprite is used to display pictures. It observes an instance of the
# Game_Picture class and automatically changes sprite states.
#==============================================================================

class Sprite_Picture
	#--------------------------------------------------------------------------
	# * Alias
	#--------------------------------------------------------------------------
	alias pictures_ee_update update 
	#--------------------------------------------------------------------------
	# * Frame Update
	#--------------------------------------------------------------------------
	def update
		pictures_ee_update
		self.mirror = !self.mirror if @picture.mirror != self.mirror
	end
end

#==============================================================================
# ** Command
#------------------------------------------------------------------------------
# Adds easily usable commands
#==============================================================================

module Command
	#--------------------------------------------------------------------------
	# * Flip horizontal of a picture
	#--------------------------------------------------------------------------
	def picture_flip(id)
		screen = $game_map.respond_to?(:screen) ? $game_map.screen : $game_screen
		screen.pictures[id].mirror = !screen.pictures[id].mirror
	end
end