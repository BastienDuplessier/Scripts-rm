# Colorise certains objets
# Depend du Script Typed Entities 
# ici : https://github.com/Funkywork/Scripts-rm/blob/master/VXAce/Typed-Entity.rb
# Pour qu'un objet (objet, arme, armure) soit colorisé, il faut que dans sa "note" (BDD)
# il y ait : <color r="valeur" v="valeur" b="valeur" />
# la valeur peut aller de 0 à 255

# Auteur : S4suk3 (Biloucorp http://www.biloucorp.com)
#==============================================================================
# ** Window_ItemList
#------------------------------------------------------------------------------
#  This window displays a list of party items on the item screen.
#==============================================================================

class Window_ItemList
  #--------------------------------------------------------------------------
  # * Draw Item Name
  #     enabled : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
		command = item.note.to_cmd_list
		color = normal_color
		if command["color"]
			r = command["color"]["r"].value.to_i
			v = command["color"]["v"].value.to_i
			b = command["color"]["b"].value.to_i
			color = Color.new(r, v, b)
		end
    draw_icon(item.icon_index, x, y, enabled)
    change_color(color, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
  end
end
