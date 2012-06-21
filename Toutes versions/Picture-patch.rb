# Notice d'utilisation par Raho :)
# ======================================================
# utiliser la commande "Appeller Script" (page 3 des évents)
# Et appeller :
# Pour changer l'opacité => Picture.change_opacity(ID_DE_LA_PICTURE, VALEUR_OPACITE)
# Pour changer l'opacité selon une variable => Picture.change_opacity(ID_DE_LA_PICTURE, ID DE LA VARIABLE)
# Pour changer le zoom => Picture.change_zoom(ID_DE_LA_PICTURE, VALEUR ZOOM X, VALEUR ZOOM Y)
# Pour changer le zoom selon une variable => Picture.change_zoom_by_var(ID_DE_LA_PICTURE, VARIABLE POUR X, ID VARIABLE POUR Y)

class Game_Picture
	attr_accessor :opacity, :zoom_x, :zoom_y
end
module Picture
	extend self
	def get_screen
		$game_map.respond_to?(:screen) ? $game_map.screen : $game_screen
	end
	def change_opacity(id, value)
		value %=256
		Picture.get_screen.pictures[id].opacity = value
	end
	def change_opacity_by_var(id, id_var)
		change_opacity(id, $game_variables[id_var])
	end
	def change_zoom(id, val_x, val_y)
		val_x = val_x.abs
		val_y = val_y.abs
		Picture.get_screen.pictures[id].zoom_x = val_x
		Picture.get_screen.pictures[id].zoom_y = val_y
	end
	def change_zoom_by_var(id, id_var_x, id_var_y)
		change_zoom(id, $game_variables[id_var_x], $game_variables[id_var_y])
	end
end
