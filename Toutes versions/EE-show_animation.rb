# Show Animation
# appel = cmd(:show_animation, event_id, anim_id)
# (donc possibilité d'utiliser variables locales et globales pour accéder à un event ou une anim)
# idée de Raymo
#==============================================================================
# ** Command
#------------------------------------------------------------------------------
# Adds easily usable commands
#==============================================================================

module Command
  #--------------------------------------------------------------------------
  # * Show animation on event
  #--------------------------------------------------------------------------
  def show_animation(ev, id)
    character = (ev == 0) ? $game_player : $game_map.events[ev]
    character.animation_id = id if character
  end
end