
#==============================================================================
# ** Perspective_Util
#------------------------------------------------------------------------------
#  Gestion de la perspective
#==============================================================================

module Perspective_Util
	TABLE = Array.new
	# Pour ajouter une gestion de la perspective pour une carte ajouter cecien dessous:
	# TABLE << {:id=>id_de_la_carte, :max=>zoom_max en %, :min=>taille_minimum en %}
	
	TABLE << {:id=>1, :max=>120, :min=>100}
	TABLE << {:id=>2, :max=>300, :min=>50}

	def self.table
		return TABLE
	end
end

#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display the character.It observes the Game_Character
#  class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Character
	#--------------------------------------------------------------------------
	# * alias
	#--------------------------------------------------------------------------
	alias perspective_update update
	#--------------------------------------------------------------------------
	# * Frame Update
	#--------------------------------------------------------------------------
	def update
		perspective_update
		value = persp_calculus
		self.zoom_x = value
		self.zoom_y = value
	end
	def persp_calculus
		scene_check =  (defined?(SceneManager)) ? SceneManager.scene_is?(Scene_Map) : $scene.is_a?(Scene_Map)
		persp_data = Perspective_Util.table.find{|elt| elt[:id] == $game_map.map_id}
		if scene_check && persp_data != nil
			height = ($game_map.height.to_f)*128
			max = persp_data[:max]
			min = persp_data[:min]
			coeff_zoom = (max - min)
			coeff_distance = (@character.real_y/height)
			value_zoom = coeff_distance * coeff_zoom
			return ((min.to_f)/100)+((value_zoom.to_f)/100)
		end
		return 1.0
	end
end
